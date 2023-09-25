class CreateWallet < ActiveRecord::Migration[5.0]
  def change
    create_table :wallets do |t|
      t.references :profile, foreign_key: true
      t.integer :coins
    end
  end
end
