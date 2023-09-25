class RemoveBookingDateFromBooking < ActiveRecord::Migration[5.0]
  def change
    remove_column :bookings, :booking_date, :datetime
  end
end
