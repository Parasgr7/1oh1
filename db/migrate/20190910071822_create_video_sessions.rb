class CreateVideoSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :video_sessions do |t|
      t.integer :booking_id
      t.integer :profile_id

      t.timestamps
    end
  end
end
