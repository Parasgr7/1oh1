class SessionsController < ApplicationController
  def index
    if !params["explore_id"].nil?
      @companion = Explore.find(params["explore_id"])
      if !current_user.profile.guide_category_ids.include? @companion.category_id.to_i
        respond_to do |format|
          format.html { redirect_to :back ,alert: 'Add Category in your Guide list'}
          format.json { head :no_content }
        end
      elsif @companion.profile.user_id.to_i == current_user.id
        render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
      end
    elsif !params["guide_id"].nil?
      @companion = Guide.find(params["guide_id"])
      if !current_user.profile.explore_category_ids.include? @companion.category_id
        respond_to do |format|
          format.html { redirect_to :back ,alert: 'Add Category in your Explore list'}
          format.json { head :no_content }
        end
      elsif @companion.profile.user_id.to_i == current_user.id
        render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
      end
    end
  end

  def new
    @booking = Booking.new
    #@balance = !current_profile.wallet.coins.nil? ? current_profile.wallet.coins : 100
    @balance = 100
  end

  def create
    head :no_content
    # ActionCable.server.broadcast 'session_channel_'+id.to_s, session_params
    ActionCable.server.broadcast( "session_channel_#{session_params[:session_id]}",session_params)
  end

  private

  def session_params
    params.permit(:type, :from, :session_id, :to, :sdp, :candidate)
  end
end
