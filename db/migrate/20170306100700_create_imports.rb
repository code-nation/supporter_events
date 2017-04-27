class CreateImports < ActiveRecord::Migration[5.0]
  def change
    create_table :imports do |t|
      t.string :name
      t.string :import_type

      t.timestamps
    end
  end
end
