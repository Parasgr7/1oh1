class ChangeContactNoToBeStringInProfiles < ActiveRecord::Migration[5.0]
  def change
    change_column :profiles, :contact_no, :string
  end
end
