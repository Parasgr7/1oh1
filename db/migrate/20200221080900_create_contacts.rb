class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.string :message
      t.string :linkedin_url
      t.integer :type
      t.timestamps
    end
  end
end
