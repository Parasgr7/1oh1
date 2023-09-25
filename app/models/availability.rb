class Availability < ApplicationRecord
  belongs_to :profile
  serialize :timing
end
