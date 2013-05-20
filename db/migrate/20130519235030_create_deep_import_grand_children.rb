class CreateDeepImportGrandChildren < ActiveRecord::Migration
  def change
    create_table :deep_import_grand_children do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_child_id
    end
    add_index :deep_import_grand_children, [:deep_import_id, :deep_import_child_id], :name => 'di_child'
  end
end
