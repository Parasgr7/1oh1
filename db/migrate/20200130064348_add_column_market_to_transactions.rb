class AddColumnMarketToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_reference :transactions, :market, foreign_key: true
  end
end
