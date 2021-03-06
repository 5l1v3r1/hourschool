class ApplicationController < ActionController::Base
  rescue_from Koala::Facebook::APIError , :with => :facebook_error

  include UrlHelper

  before_filter :debug, :eventual_warm_facebook_cache, :hide_private_accounts
  protect_from_forgery

  protected
    def debug
    end

    # def fix_double_subdomain
    #   if request.subdomain.match(/www\..*/)
    #     correct_subdomain = request.subdomain.gsub("www.", "")
    #     redirect_to request.url.gsub("//#{request.subdomain}", "//#{correct_subdomain}"), :status => 301
    #   end
    # end

    helper_method :current_account
    def current_account
      @current_account ||= if request.subdomain.present?
        Account.where(:subdomain => request.subdomain.downcase).first
      end
    end

    helper_method :admin_of_current_account?
    def admin_of_current_account?
      authenticate_user!
      user_signed_in? && (current_user.admin? || (current_account && Membership.find_by_account_id_and_user_id_and_admin(current_account.id, current_user.id, true)))
    end


    helper_method :community_site?
    def community_site?
      current_account.nil?
    end

    def hide_private_accounts
      if current_account && current_account.private? && !user_signed_in?
        redirect_to new_user_session_path
      end
    end

    # # remove the www. from our URL ensures facebook auth works
    # # and ensures we don't accidentally swap domains while a user
    # # is logged in (which makes it look like the user gets logged out)
    # def ensure_domain
    #   if request.subdomain == 'www'
    #     redirect_to request.url.gsub("//www.", '//'), :status => 301
    #   end
    # end

    def eventual_warm_facebook_cache
      enqueue_warm_facebook_cache if rand(4) == 1 # one in 5 chance
    end

    def enqueue_warm_facebook_cache
      return true if current_user.blank? || current_user.no_facebook?
      return true if current_user.cache.exist?(:facebook_friend_locations)
      Rails.logger.warn '==== run `bundle exec rake resque:work VVERBOSE=1 QUEUE=*` to ensure facebook cache is getting set' unless Rails.env.production?
      Resque.enqueue(User::Facebook::FullCacheWarm, current_user.id)
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
      unless admin_of_current_account? || current_user.admin?
        redirect_to root_path
      end
    end

    def log_error(exception)
      message = "#{exception.class} (#{exception.message}):\n  "
      message += Rails.backtrace_cleaner.clean(exception.backtrace).join("\\n")
      Rails.logger.fatal(message)
    end

    def facebook_error(exception)
      log_error(exception)
      notify_airbrake(exception)
      logger.error "There was a problem authenticating with Facebook, login again using Facebook"
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
      redirect_to root_path if current_user.present?
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

    def store_location(url = nil)
      session[:return_to] = url||request.url
    end

    def store_referrer
      session[:return_to] = request.referrer
    end


    def after_sign_in_path_for(resource)
      previous_path_or(root_path)
    end

end
