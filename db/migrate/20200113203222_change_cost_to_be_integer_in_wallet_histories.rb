class ChangeCostToBeIntegerInWalletHistories < ActiveRecord::Migration[5.0]
  def change
    change_column :wallet_histories, :cost, 'integer USING CAST(cost AS integer)'

  end
end
