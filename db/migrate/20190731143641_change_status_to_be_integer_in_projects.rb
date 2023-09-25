class ChangeStatusToBeIntegerInProjects < ActiveRecord::Migration[5.0]
  def change
    change_column :projects, :status, :integer,using: 'status::integer'
  end
end
