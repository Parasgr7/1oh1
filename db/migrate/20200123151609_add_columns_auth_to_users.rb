class AddColumnsAuthToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column(:users, :provider, :string, limit: 50, null: false, default: '')
    add_column(:users, :uid, :string, limit: 500, null: false, default: '')
    add_column(:users, :sign_in_count, :integer, null: false, default: 0)

  end
end
