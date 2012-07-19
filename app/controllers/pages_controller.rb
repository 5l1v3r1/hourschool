class PagesController < ApplicationController
  layout 'application', :except => :index

  # homepage
  def index
    @pre_mission_signup = PreMissionSignup.new
    @mission = Mission.new
    @courses = Course.active.order(:starts_at, :created_at)
    if community_site?
      @courses = @courses.community
      if current_user
        @no_courses_in_user_city = current_user.city.try(:name).nil? || current_user.city.courses.empty?
      else
        @no_courses_in_user_city = false
      end
    else
      @courses = @courses.where(:account_id => current_account.id)
    end
    
    if community_site?
      # @featured_courses = Course.where(:featured => true).order("created_at desc").first(4)
      @fav2 = Course.where(:id => 392).first || Course.live.random.first
      @fav1 = Course.where(:id => 421).first || Course.live.random.first
      @fav3 = Course.where(:id => 438).first || Course.live.random.first
      @fav4 = Course.where(:id => 384).first || Course.live.random.first
      render :layout => 'home'
    else
      redirect_to explore_url
    end
  end

  def show
    @missions = Mission.all
    @exception = env["action_dispatch.exception"]
    if params[:id] == "campaign"
      @amount_raised = Payment.joins(:course).where("courses.donate = 'true'").select('SUM(amount) as sum').first.sum.to_f
    end
    render "pages/show/#{params[:id]}" # %w{ about apps contact ... }
  end

end
