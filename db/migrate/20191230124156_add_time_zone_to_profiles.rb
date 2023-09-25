class AddTimeZoneToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :time_zone, :string
  end
end
