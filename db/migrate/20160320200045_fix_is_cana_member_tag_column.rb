class FixIsCanaMemberTagColumn < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :is_member
    add_column :nations, :is_member, :boolean
  end
end
