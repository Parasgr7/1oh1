class ChangeCustomerIdToBeStringInProducts < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :customer_id, :string
  end
end
