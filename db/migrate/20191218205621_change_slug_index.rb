class ChangeSlugIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index(:profiles, name: 'index_profiles_on_slug')
  end
end
