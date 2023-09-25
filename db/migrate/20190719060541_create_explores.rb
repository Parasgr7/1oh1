class CreateExplores < ActiveRecord::Migration[5.0]
  def change
    create_table :explores do |t|

      t.timestamps
    end
  end
end
