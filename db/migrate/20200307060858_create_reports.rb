class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.references :profile, foreign_key: true
      t.references :reported,polymorphic: true
      t.boolean :spam, default: false
      t.boolean :mature, default: false
      t.boolean :abusive, default: false
      t.boolean :self_harm, default: false
      t.boolean :copyright, default: false

      t.timestamps
    end
  end
end
