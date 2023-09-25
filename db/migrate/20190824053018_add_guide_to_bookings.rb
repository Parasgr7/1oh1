class AddGuideToBookings < ActiveRecord::Migration[5.0]
  def change
    add_reference :bookings, :guide, :foreign_key => { :on_delete => :nullify }

  end
end
