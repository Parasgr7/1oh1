class AddColumnVerifiedToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :verified, :boolean,:default => false
  end
end
