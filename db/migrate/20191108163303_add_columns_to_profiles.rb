class AddColumnsToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :birth_date, :date
    add_column :profiles, :city, :string
  end
end
