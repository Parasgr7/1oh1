class AddColumnCoinsToMaket < ActiveRecord::Migration[5.0]
  def change
    add_column :markets, :coins, :integer
  end
end
