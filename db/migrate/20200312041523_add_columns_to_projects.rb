class AddColumnsToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :summary, :text
    add_column :projects, :gaps, :text
    add_column :projects, :challenges, :text
    add_column :projects, :tools, :text
    add_column :projects, :supplies, :text
    add_column :projects, :completion_date, :date
  end
end
