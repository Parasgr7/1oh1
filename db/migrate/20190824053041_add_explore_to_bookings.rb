class AddExploreToBookings < ActiveRecord::Migration[5.0]
  def change
    add_reference :bookings, :explore,:foreign_key => { :on_delete => :nullify }
  end
end
