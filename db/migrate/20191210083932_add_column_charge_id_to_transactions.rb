class AddColumnChargeIdToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :charge_id, :string
  end
end
