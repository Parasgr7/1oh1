class CreateProjectComments < ActiveRecord::Migration[5.0]
  def change
    create_table :project_comments do |t|
      t.references :project, foreign_key: true
      t.references :profile, foreign_key: true
      t.string :comment
      t.timestamps
    end
  end
end
