class CreateExploreRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :explore_ratings do |t|
      t.string :review
      t.integer :rating
      t.references :profile, foreign_key: true
      t.references :guide, foreign_key: true

      t.timestamps
    end
  end
end
