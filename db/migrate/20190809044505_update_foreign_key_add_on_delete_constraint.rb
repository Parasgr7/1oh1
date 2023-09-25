class UpdateForeignKeyAddOnDeleteConstraint < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :explores, :categories
    add_foreign_key :explores, :categories, on_delete: :cascade

  end
end
