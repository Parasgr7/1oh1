class AddColumnCoinToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :coins, :integer
  end
end
