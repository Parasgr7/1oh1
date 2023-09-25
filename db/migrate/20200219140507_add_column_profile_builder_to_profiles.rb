class AddColumnProfileBuilderToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :builder, :boolean,:default => false
  end
end
