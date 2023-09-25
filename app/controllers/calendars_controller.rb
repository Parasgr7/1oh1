class CalendarsController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_calendar, only: [:show, :edit, :update, :destroy]

  # GET /calendars
  # GET /calendars.json
  def index
    @booking = Booking.new
    availabilities =  current_user.profile.availabilities
    @formatted_availabilty = format_availability(availabilities)
    @personal_setting_schedule_time = current_user.profile.personal_setting.nil? ? "" : current_user.profile.personal_setting.schedule_time.nil? ? 5 : current_user.profile.personal_setting.schedule_time
    @personal_setting_buffer_time = current_user.profile.personal_setting.nil? ? "" : current_user.profile.personal_setting.buffer_time.nil? ? 0 : current_user.profile.personal_setting.buffer_time

    @personal_setting = current_user.profile.personal_setting
    if  profile_builder_complete[:profile_nil]
      flash[:notice] = 'Complete your profile first'
      redirect_to first_page_introduction_path
    elsif profile_builder_complete[:all_empty]
      flash[:notice] = 'Complete your Availability first'
      redirect_to availabilty_introduction_path
    else
      current_user.update(builder: true)
    end
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
  end

  # # GET /calendars/1/edit
  def edit
    @booking =  Booking.find(params[:id])
  end

end
