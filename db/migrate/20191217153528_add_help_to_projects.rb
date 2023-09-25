class AddHelpToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :help, :boolean
  end
end
