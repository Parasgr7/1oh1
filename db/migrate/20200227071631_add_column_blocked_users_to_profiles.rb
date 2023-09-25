class AddColumnBlockedUsersToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :blocked_users, :string
  end
end
