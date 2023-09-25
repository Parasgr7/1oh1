class ProjectComment < ApplicationRecord
  belongs_to :profile
  belongs_to :project
  scope :sort_by_created_desc, -> {order(created_at: :desc)}

end
