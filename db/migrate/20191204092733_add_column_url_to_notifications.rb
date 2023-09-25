class AddColumnUrlToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :url, :string
  end
end
