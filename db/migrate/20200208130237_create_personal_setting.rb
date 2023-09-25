class CreatePersonalSetting < ActiveRecord::Migration[5.0]
  def change
    create_table :personal_settings do |t|
      t.references :profile, foreign_key: true
      t.boolean :new_message,:default => false
      t.boolean :after_booking,:default => true
      t.boolean :change_request,:default => true
      t.boolean :booking_decline,:default => true
      t.boolean :coins_purchased,:default => true
      t.boolean :change_session_details,:default => true
      t.boolean :booking_pending,:default => false
      t.boolean :change_request_accepted,:default => true
      t.boolean :hour_reminder,:default => true
      t.boolean :new_rating,:default => false
      t.boolean :news_letter,:default => false
      t.boolean :suggestion,:default => false

    end
  end
end
