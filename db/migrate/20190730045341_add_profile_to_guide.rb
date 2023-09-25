class AddProfileToGuide < ActiveRecord::Migration[5.0]
  def change
    add_reference :guides, :profile, foreign_key: true
  end
end
