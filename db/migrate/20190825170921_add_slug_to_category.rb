class AddSlugToCategory < ActiveRecord::Migration[5.0]
  def change
    change_table :categories do |t|
    t.string :slug, after: :id
  end
  end
end
