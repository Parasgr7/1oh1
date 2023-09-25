class ApplicationController < ActionController::Base
  protect_from_forgery  unless: -> { request.format.json? }

  before_action :user_time_zone, if: :logged_in?
  # skip_before_action :verify_authenticity_token, raise: false
  # before_action :authenticate_user!
  include UsersHelpers, ApplicationHelper
  helper_method :current_profile

  private
  def user_time_zone
    if !current_user.profile.nil?
      Time.zone = current_user.profile.time_zone
    end
  end


  def current_profile
    if current_user.profile
      current_user.profile
    end
  end
end
