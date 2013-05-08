class CreateDeepImportChildren < ActiveRecord::Migration
  def change
    create_table :deep_import_children do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.string :deep_import_parent_id

      t.timestamps
    end
  end
end
