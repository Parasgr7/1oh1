class ChangeDurationToBeStringInBookings < ActiveRecord::Migration[5.0]
  def change
    change_column :bookings, :duration, :string
  end
end
