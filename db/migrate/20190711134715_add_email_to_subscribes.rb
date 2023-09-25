class AddEmailToSubscribes < ActiveRecord::Migration[5.0]
  def change
    add_column :subscribes, :email, :string
  end
end
