class AddColabIdToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :colab_id, :string
  end
end
