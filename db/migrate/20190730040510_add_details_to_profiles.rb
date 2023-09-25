class AddDetailsToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :state, :string
    add_column :profiles, :country, :string
    add_column :profiles, :profile_photo, :string
    add_column :profiles, :banner_photo, :string
    add_column :profiles, :languages, :string
    add_column :profiles, :bio, :string
    add_column :profiles, :contact_no, :integer
  end
end
