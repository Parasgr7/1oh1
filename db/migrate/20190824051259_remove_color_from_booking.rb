class RemoveColorFromBooking < ActiveRecord::Migration[5.0]
  def change
    remove_column :bookings, :color, :string
  end
end
