class UpdateForeignKeyAddGuideRating < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :guide_ratings, :explores
    add_foreign_key :guide_ratings, :explores, on_delete: :cascade
  end
end
