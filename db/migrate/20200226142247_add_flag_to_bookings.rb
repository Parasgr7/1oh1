class AddFlagToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :flag, :boolean, :default => false
  end
end
