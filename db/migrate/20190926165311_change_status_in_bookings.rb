class ChangeStatusInBookings < ActiveRecord::Migration[5.0]
  def change
    change_column :bookings, :status, :integer,using: 'status::integer'

  end
end
