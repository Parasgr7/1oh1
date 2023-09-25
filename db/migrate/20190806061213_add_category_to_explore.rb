class AddCategoryToExplore < ActiveRecord::Migration[5.0]
  def change
    add_reference :explores, :category, foreign_key: true
  end
end
