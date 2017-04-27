class AddSlugIndexToNation < ActiveRecord::Migration[5.0]
  def change
    add_index :nations, :slug, unique: true
  end
end
