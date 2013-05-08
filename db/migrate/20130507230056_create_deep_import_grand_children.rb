class CreateDeepImportGrandChildren < ActiveRecord::Migration
  def change
    create_table :deep_import_grand_children do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.string :deep_import_child_id

      t.timestamps
    end
  end
end
