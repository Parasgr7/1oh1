class AddCategoryInExploreRatings < ActiveRecord::Migration[5.0]
  def change
    add_reference :explore_ratings, :category, foreign_key: true
  end
end
