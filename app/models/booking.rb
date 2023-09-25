class Booking < ApplicationRecord
  extend FriendlyId
  friendly_id :identifier
  belongs_to :explore
  belongs_to :guide
  has_many :video_sessions, dependent: :destroy
  #if chat is destroyed all video_sessions will also be  destroyed
  has_many :profiles, through: :video_sessions
  has_many :wallet_histories, foreign_key: :action_id
  validates :identifier, presence: true, uniqueness: true,case_sensitive: false

  validates :title, presence: true
  attr_accessor :date_range

  scope :my_pending, -> (profile_id){where(:status=>0,:recipient_id=>profile_id)}
  scope :sort_descending, -> {order(updated_at: :desc)}
  def all_day_booking?
    self.start == self.start.midnight && self.end == self.end.midnight ? true : false
  end
  enum status: [:pending, :upcoming, :completed, :unavailable]
end
