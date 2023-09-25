class RenameUnavailabilityToAvailability < ActiveRecord::Migration[5.0]
  def change
    rename_table :unavailabilties, :availabilities
    add_column :availabilities, :start_time, :time
    add_column :availabilities, :end_time, :time
  end
end
