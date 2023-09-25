class AddGuideReferenceToGuideRatings < ActiveRecord::Migration[5.0]
  def change
    add_reference :guide_ratings, :guide, :foreign_key => { :on_delete => :cascade }
  end
end
