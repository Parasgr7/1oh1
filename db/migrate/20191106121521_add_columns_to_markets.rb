class AddColumnsToMarkets < ActiveRecord::Migration[5.0]
  def change
    add_column :markets, :name, :string
    add_column :markets, :currency, :string
    add_column :markets, :mode, :string
    add_column :markets, :interval, :string
    add_column :markets, :price, :integer
    add_column :markets, :offer, :string
  end
end
