class CreateGuides < ActiveRecord::Migration[5.0]
  def change
    create_table :guides do |t|

      t.timestamps
    end
  end
end
