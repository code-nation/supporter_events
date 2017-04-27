class CreateNations < ActiveRecord::Migration[5.0]
  def change
    create_table :nations do |t|
      t.string :slug
      t.integer :user_id
      t.string :token

      t.timestamps null: false
    end
  end
end
