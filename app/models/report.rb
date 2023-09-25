class Report < ApplicationRecord
  belongs_to :reported, polymorphic: true, optional: true
  belongs_to :profile
end
