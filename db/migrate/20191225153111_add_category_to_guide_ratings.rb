class AddCategoryToGuideRatings < ActiveRecord::Migration[5.0]
  def change
    add_reference :guide_ratings, :category, foreign_key: true
  end
end
