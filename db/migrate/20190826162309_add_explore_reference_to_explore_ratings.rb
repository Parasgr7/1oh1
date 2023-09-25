class AddExploreReferenceToExploreRatings < ActiveRecord::Migration[5.0]
  def change
    add_reference :explore_ratings, :explore, :foreign_key => { :on_delete => :cascade }
  end
end
