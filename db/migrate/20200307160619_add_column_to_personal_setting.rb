class AddColumnToPersonalSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :personal_settings, :schedule_time, :integer
    add_column :personal_settings, :buffer_time, :integer
  end
end
