class CreateCategoriesProjectsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_join_table :categories, :projects
  end
end
