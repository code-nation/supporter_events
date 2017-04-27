class RemoveIsMemberFromNations < ActiveRecord::Migration[5.0]
  def change
    remove_column :nations, :is_member, :boolean
  end
end
