class CreateDeepImportParents < ActiveRecord::Migration
  def change
    create_table :deep_import_parents do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.timestamps
    end
  end
end
