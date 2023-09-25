class ReportsController < ApplicationController
  before_action :authenticate_user!
  def create
    @report = Report.new(report_params)
    @report.profile = current_user.profile
    if params[:profile_reported]
      @report.reported = Profile.find_by_id(params[:profile_reported])
    elsif params["category_reported"]
      @report.reported = Category.verified.find_by_slug(params[:category_reported])
    end
    flash.now[:success] = "Reported, will take action soon!"
    @flashing = flash
    if @report.save
      respond_to do |format|
        format.js
      end
    end

  end

  def block_user
    profile = current_user.profile
    blocking_user = Profile.find_by_id(params[:profile_block].to_i)
    if !params[:profile_block].nil?
      if !(profile.blocked_users.include? params[:profile_block].to_i)
        profile.blocked_users << params[:profile_block].to_i
        profile.save!
      end
      if !(blocking_user.blocked_users.include? profile.id)
        blocking_user.blocked_users << profile.id
        blocking_user.save!
      end
    end
    flash[:success] = "Blocked!"
    redirect_to  authenticated_root_path
  end

  private

  def report_params
    params.permit(:spam,:mature,:self_harm,:abusive,:copyright)
  end
end
