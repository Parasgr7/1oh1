class AddHelpColumnToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :help_needed, :string
    change_column :projects, :tools, :string
    change_column :projects, :supplies, :string
  end
end
