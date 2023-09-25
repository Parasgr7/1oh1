class AddColumnIndetifierToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :identifier, :string
  end
end
