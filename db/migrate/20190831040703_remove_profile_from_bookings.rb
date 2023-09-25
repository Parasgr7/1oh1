class RemoveProfileFromBookings < ActiveRecord::Migration[5.0]
  def change
    remove_reference :bookings, :profile, foreign_key: true
  end
end
