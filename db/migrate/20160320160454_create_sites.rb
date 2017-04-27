class CreateSites < ActiveRecord::Migration[5.0]
  def change
    create_table :sites do |t|
      t.string :slug
      t.integer :nation_id
      t.integer :nb_site_id

      t.timestamps null: false
    end
    add_index :sites, :nation_id
  end
end
