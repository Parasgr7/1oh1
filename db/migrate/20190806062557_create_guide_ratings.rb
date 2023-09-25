class CreateGuideRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :guide_ratings do |t|
      t.string :review
      t.integer :rating
      t.references :profile, foreign_key: true
      t.references :explore, foreign_key: true

      t.timestamps
    end
  end
end
