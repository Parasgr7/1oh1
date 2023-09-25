class CreateUnavailabilties < ActiveRecord::Migration[5.0]
  def change
    create_table :unavailabilties do |t|
      t.integer :week_day
      t.references :profile, foreign_key: true
      t.string :timing
      t.boolean :full_day_off, :default => false

      t.timestamps
    end
  end
end
