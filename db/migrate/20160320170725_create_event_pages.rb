class CreateEventPages < ActiveRecord::Migration[5.0]
  def change
    create_table :event_pages do |t|
      t.string :slug
      t.integer :nb_event_page_id
      t.integer :site_id
      t.json :object

      t.timestamps null: false
    end
    add_index :event_pages, :site_id
  end
end