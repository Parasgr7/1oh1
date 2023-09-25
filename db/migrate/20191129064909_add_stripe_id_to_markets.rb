class AddStripeIdToMarkets < ActiveRecord::Migration[5.0]
  def change
    add_column :markets, :stripe_id, :string
  end
end
