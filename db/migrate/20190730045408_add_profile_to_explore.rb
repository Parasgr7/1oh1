class AddProfileToExplore < ActiveRecord::Migration[5.0]
  def change
    add_reference :explores, :profile, foreign_key: true
  end
end
