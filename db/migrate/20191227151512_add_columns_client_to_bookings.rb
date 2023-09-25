class AddColumnsClientToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :client_id, :integer
    add_column :bookings, :recipient_id, :integer
  end
end
