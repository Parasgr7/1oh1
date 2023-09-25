class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notification = Notification.includes(:recipient,:notifiable, user:[:profile])
    @all_notifications = current_user.notifications.sort_by_date
    @notifications = @notification.where(:recipient => current_user).unread
    @earlier_notifications = @notification.where(:recipient => current_user).read
  end

  def mark_as_read
    @notification = Notification.find(params[:id])
    @notification.update(read_at: Time.zone.now)
    render json: {success: true}
  end

  def unread_messages
  end

  def update
    @notification = Notification.find(params[:id])
    @notification.update(read_at: Time.zone.now)
    @url = @notification.url
    respond_to do |format|
      format.js
    end
  end

  def send_message_notif
    Notification.create(recipient: User.find(params[:to]), user: User.find(params[:from]), action: "followed", notifiable: User.find(params[:to]))
  end
end
