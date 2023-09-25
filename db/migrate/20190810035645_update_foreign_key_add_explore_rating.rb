class UpdateForeignKeyAddExploreRating < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :explore_ratings, :guides
    add_foreign_key :explore_ratings, :guides, on_delete: :cascade
  end
end
