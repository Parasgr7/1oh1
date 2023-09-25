class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :recipient, class_name: "User"
  belongs_to :notifiable, polymorphic: true
  after_create_commit -> { NotificationRelayJob.perform_later(self) }

  scope :unread, -> {where(read_at: nil).order(updated_at: :desc)}
  scope :sort_by_date, -> {order(updated_at: :desc)}
  scope :read, -> {where.not(read_at: nil).order(updated_at: :desc)}
end
