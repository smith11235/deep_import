class AddDeepImportEnhancements < ActiveRecord::Migration[5.2]
  def change
    add_column :parents, :deep_import_id, :string, :references => false
    add_index :parents, [:deep_import_id, :id], :name => 'di_id_9292d84064b4ffecb3d5a9878f5fdeb8'
    add_column :children, :deep_import_id, :string, :references => false
    add_index :children, [:deep_import_id, :id], :name => 'di_id_cd32b2089b38315267372441b14914ac'
    add_column :grand_children, :deep_import_id, :string, :references => false
    add_index :grand_children, [:deep_import_id, :id], :name => 'di_id_4b28a2b058ab07f15071d1402d5590e0'
    create_table :deep_import_parents do |t|
      t.string :deep_import_id, :references => false
      t.datetime :parsed_at
      t.timestamps
    end
    create_table :deep_import_children do |t|
      t.string :deep_import_id, :references => false
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_parent_id, :references => false
    end
    add_index :deep_import_children, [:deep_import_id, :deep_import_parent_id], :name => 'di_parent_0c6da0a3037bb9f6c5848bcf79c224cd'
    create_table :deep_import_grand_children do |t|
      t.string :deep_import_id, :references => false
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_child_id, :references => false
    end
    add_index :deep_import_grand_children, [:deep_import_id, :deep_import_child_id], :name => 'di_child_933657180e6efce59e0a77c13286bf29'
  end
end
