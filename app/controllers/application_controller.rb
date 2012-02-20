class ApplicationController < ActionController::Base
  rescue_from Koala::Facebook::APIError , :with => :facebook_error

  include UrlHelper

  before_filter :debug, :ensure_domain, :set_timezone, :eventual_warm_facebook_cache
  protect_from_forgery

  protected
    def debug
    end

    def current_account
      @current_account ||= if request.subdomain.present?
        Account.where(:subdomain => request.subdomain.downcase).first
      end
    end

    def invalid_user_for_subdomain?
      current_user && current_account && current_account.invalid_user?(current_user)
    end

    def require_account_for_subdomain!
      if invalid_user_for_subdomain?
        flash[:error] = "You need to sign up with a #{current_account.name} email address"
        sign_out_and_redirect(new_user_session_path)
      end
    end

    # remove the www. from our URL ensures facebook auth works
    # and ensures we don't accidentally swap domains while a user
    # is logged in (which makes it look like the user gets logged out)
    def ensure_domain
      if request.subdomain == 'www'
        redirect_to request.url.gsub("//www.", '//'), :status => 301
      else
        require_account_for_subdomain!
      end
    end

    def eventual_warm_facebook_cache
      enqueue_warm_facebook_cache if rand(4) == 1 # one in 5 chance
    end

    def enqueue_warm_facebook_cache
      return true if current_user.blank? || current_user.no_facebook?
      return true if current_user.cache.exist?(:facebook_friend_locations)
      Rails.logger.warn '==== run `rake jobs:work` to ensure facebook cache is getting set' unless Rails.env.production?
      job = User::Facebook::FullCacheWarm.new(current_user.id)
      Delayed::Job.enqueue(job)
    rescue => ex
      facebook_error(ex)
    end

    alias :devise_authenticate_user! :authenticate_user!

    def authenticate_user!(*args)
      store_location unless signed_in?
      devise_authenticate_user!(*args)
    end

    def authenticate_admin!
      authenticate_user!
      redirect_to root_path unless current_user.admin?
    end

    def log_error(exception)
      message = "#{exception.class} (#{exception.message}):\n  "
      message += Rails.backtrace_cleaner.clean(exception.backtrace).join("\\n")
      Rails.logger.fatal(message)
    end

    def facebook_error(exception)
      log_error(exception)
      notify_airbrake(exception)
      flash[:notice] = "There was a problem authenticating with Facebook, login again using Facebook"
      redirect_to destroy_user_session_path
    end


    def send_error_to_new_relic(exception)
      rack_env = ENV.to_hash.merge(request.env)
      rack_env.delete('rack.session.options')

      opts = {
        :request_params => params,
        :custom_params => {
          :session => session,
          :rack => rack_env
        }
      }
      NewRelic::Agent.notice_error(exception, opts)
    end


    def skip_if_logged_in
      redirect_to learn_path if current_user.present?
    end

    def set_timezone
      Time.zone = TZInfo::Timezone.get(current_user.time_zone) if current_user.present? && current_user.time_zone.present?
    rescue => ex
      send_error_to_new_relic(ex)
    end

    def previous_path_or(url)
      return_to = session[:return_to]
      return_to.gsub!('//www.', '//') unless return_to.blank?
      if return_to.present? && return_to != '/'
        session[:return_to] = nil
        return_to
      else
        url
      end
    end

    def store_location
      session[:return_to] = request.url
    end

    def store_referrer
      session[:return_to] = request.referrer
    end


    def after_sign_in_path_for(resource)
      previous_path_or(learn_path)
    end

end
