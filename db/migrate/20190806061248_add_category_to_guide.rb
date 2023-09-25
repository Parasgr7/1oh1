class AddCategoryToGuide < ActiveRecord::Migration[5.0]
  def change
    add_reference :guides, :category, foreign_key: true
  end
end
