class HelpsController < ApplicationController
  before_action :authenticate_user!

  # GET /helps
  # GET /helps.json
  def index
    @personal_settings = current_profile.personal_setting
    @filterrific = initialize_filterrific(
      Category.verified,
      params[:filterrific]
    ) or return
   @categories = @filterrific.find.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
    availabilities =  current_user.profile.availabilities
    @formatted_availabilty = format_availability(availabilities)
    @personal_setting = current_user.profile.personal_setting
    @personal_setting_schedule_time = current_user.profile.personal_setting.nil? ? "" : current_user.profile.personal_setting.schedule_time.nil? ? 5 : current_user.profile.personal_setting.schedule_time
    @personal_setting_buffer_time = current_user.profile.personal_setting.nil? ? "" : current_user.profile.personal_setting.buffer_time.nil? ? 0 : current_user.profile.personal_setting.buffer_time

  end

  def update_settings
    @personal_settings = current_profile.personal_setting
    all = {new_message: false, after_booking: false, change_request: false, booking_decline: false, coins_purchased: false, change_session_details: false, booking_pending: false, change_request_accepted: false, hour_reminder: false, new_rating: false, news_letter: false, suggestion: false}
    if @personal_settings.nil?
      #first time creation
      @setting_instance = PersonalSetting.new
      help_params.each do |key,value|
        all[key] = (value=="on")
      end
      all.each do |key,val|
        @setting_instance[key] = val
      end
      @setting_instance.profile = current_profile

      @setting_instance.save!
      flash.now[:success] = "Prefrences Created!!!"
      puts @setting_instance
    else
      #updating
      help_params.each do |key,value|
        all[key] = (value=="on")
      end
      puts all
      @personal_settings.update_attributes(all)
      flash.now[:success] = "Prefrences Updated!!!"
    end
    @flashing = flash
    respond_to do |format|
      format.js
    end
  end

  def states
    render json: CS.states(params[:country]).to_json
  end

  def cities
    render json: CS.cities(params[:state],params[:country]).to_json
  end
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def help_params
      params.permit(:new_message,:after_booking,:change_request,:change_session_details,:booking_pending,:change_request_accepted,:hour_reminder,:coins_purchased,:new_rating,:news_letter,:suggestion,:booking_decline)
    end

end
