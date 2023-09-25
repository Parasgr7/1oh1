class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.references :profile, foreign_key: true
      t.string :name
      t.string :currency
      t.string :mode
      t.string :interval
      t.integer :price
      t.integer :customer_id
      t.integer :product_id

      t.timestamps
    end
  end
end
