class CreateBookings < ActiveRecord::Migration[5.0]
  def change
    create_table :bookings do |t|
      t.string :title
      t.datetime :start
      t.datetime :end
      t.string :color
      t.integer :duration
      t.datetime :booking_date
      t.datetime :cancel_date
      t.boolean :status

      t.timestamps
    end
  end
end
