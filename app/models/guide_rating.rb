class GuideRating < ApplicationRecord
  belongs_to :profile
  belongs_to :explore
  belongs_to :guide
  belongs_to :category

  scope :rate_desc,-> {order("rating DESC")}
  scope :rate_asc,-> {order("rating ASC")}
  scope :sort_by_created_desc, -> {order(created_at: :desc)}
  def self.average_rating(profile,category_id)
    if !category_id.nil?
      where(:profile=>profile,:category_id=>category_id)
    else
      where(:profile=>profile)
    end
  end

end
