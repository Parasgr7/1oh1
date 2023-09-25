class AddSlugToChat < ActiveRecord::Migration[5.0]
  def change
    change_table :chats do |t|
    t.string :slug, after: :id
  end
  end
end
