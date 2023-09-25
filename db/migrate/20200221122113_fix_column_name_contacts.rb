class FixColumnNameContacts < ActiveRecord::Migration[5.0]
  def change
    rename_column :contacts, :type, :category

  end
end
