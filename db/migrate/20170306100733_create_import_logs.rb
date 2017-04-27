class CreateImportLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :import_logs do |t|
      t.integer :row
      t.integer :status
      t.string :message
      t.references :import, foreign_key: true

      t.timestamps
    end
  end
end
