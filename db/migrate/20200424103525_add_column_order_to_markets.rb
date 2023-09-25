class AddColumnOrderToMarkets < ActiveRecord::Migration[5.0]
  def change
    add_column :markets, :order, :integer
  end
end
