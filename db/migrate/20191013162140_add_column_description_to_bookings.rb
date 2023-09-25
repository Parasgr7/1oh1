class AddColumnDescriptionToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :description, :string
  end
end
