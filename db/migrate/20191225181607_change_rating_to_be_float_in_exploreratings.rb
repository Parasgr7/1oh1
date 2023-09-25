class ChangeRatingToBeFloatInExploreratings < ActiveRecord::Migration[5.0]
  def change
    change_column :explore_ratings, :rating, :float
  end
end
