class CreateDeepImportChildren < ActiveRecord::Migration
  def change
    create_table :deep_import_children do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_parent_id
    end
    add_index :deep_import_children, [:deep_import_id, :deep_import_parent_id], :name => 'di_parent'
  end
end
