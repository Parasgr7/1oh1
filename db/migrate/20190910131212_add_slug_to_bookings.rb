class AddSlugToBookings < ActiveRecord::Migration[5.0]
  def change
    change_table :bookings do |t|
    t.string :slug, after: :id
  end
  end
end
