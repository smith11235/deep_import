class AddDeepImportEnhancements < ActiveRecord::Migration
  def change
    add_column :parents, :deep_import_id, :string
    add_index :parents, [:deep_import_id, :id], :name => 'di_id_index'
    add_column :children, :deep_import_id, :string
    add_index :children, [:deep_import_id, :id], :name => 'di_id_index'
    add_column :grand_children, :deep_import_id, :string
    add_index :grand_children, [:deep_import_id, :id], :name => 'di_id_index'
    create_table :deep_import_parents do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.timestamps
    end
    create_table :deep_import_children do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_parent_id
    end
    add_index :deep_import_children, [:deep_import_id, :deep_import_parent_id], :name => 'di_parent'
    create_table :deep_import_grand_children do |t|
      t.string :deep_import_id
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_child_id
    end
    add_index :deep_import_grand_children, [:deep_import_id, :deep_import_child_id], :name => 'di_child'
  end
end
