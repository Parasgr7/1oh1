class AddColumnDescriptionToMarkets < ActiveRecord::Migration[5.0]
  def change
    add_column :markets, :description, :string
  end
end
