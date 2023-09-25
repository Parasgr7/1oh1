class AddProfileToProject < ActiveRecord::Migration[5.0]
  def change
    add_reference :projects, :profile, foreign_key: true
  end
end
