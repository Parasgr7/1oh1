class UpdateForeignKeyAddOnDeleteConstraintGuide < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :guides, :categories
    add_foreign_key :guides, :categories, on_delete: :cascade
  end
end
