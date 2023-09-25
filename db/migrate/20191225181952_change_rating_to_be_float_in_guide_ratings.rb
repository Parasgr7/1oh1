class ChangeRatingToBeFloatInGuideRatings < ActiveRecord::Migration[5.0]
  def change
    change_column :guide_ratings, :rating, :float
  end
end
