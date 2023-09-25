class NotificationRelayJob < ApplicationJob
  queue_as :default

  def perform(notification)
    # html = ApplicationController.render partial: "notifications/#{notification.notifiable_type.underscore.pluralize}/#{notification.action}", locals: {notification: notification}, formats: [:html]
    unread = User.find_by(id: notification.recipient_id).notifications.unread.size
    ActionCable.server.broadcast "notifications:#{notification.recipient_id}", unread: unread
  end
end
