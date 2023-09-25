class AddProfileToBookings < ActiveRecord::Migration[5.0]
  def change
    add_reference :bookings, :profile, :foreign_key => { :on_delete => :nullify }
  end
end
