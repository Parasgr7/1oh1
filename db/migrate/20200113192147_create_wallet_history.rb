class CreateWalletHistory < ActiveRecord::Migration[5.0]
  def change
    create_table :wallet_histories do |t|
      t.references :wallet, foreign_key: true
      t.string :cost
      t.integer :prev_bal
      t.integer :new_bal
      t.references :action, polymorphic: true
      t.string :source
    end
  end
end
