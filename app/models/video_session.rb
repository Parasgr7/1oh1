class VideoSession < ApplicationRecord
  belongs_to :booking
  belongs_to :profile
end
