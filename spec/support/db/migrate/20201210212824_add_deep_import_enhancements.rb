class AddDeepImportEnhancements < ActiveRecord::Migration[5.2]
  def change
    add_column :parents, :deep_import_id, :string, :references => false
    add_index :parents, [:deep_import_id, :id], :name => 'di_id_9292d84064b4ffecb3d5a9878f5fdeb8'
    add_column :children, :deep_import_id, :string, :references => false
    add_index :children, [:deep_import_id, :id], :name => 'di_id_cd32b2089b38315267372441b14914ac'
    add_column :grand_children, :deep_import_id, :string, :references => false
    add_index :grand_children, [:deep_import_id, :id], :name => 'di_id_4b28a2b058ab07f15071d1402d5590e0'
    add_column :in_laws, :deep_import_id, :string, :references => false
    add_index :in_laws, [:deep_import_id, :id], :name => 'di_id_c404c405099779e386ddcbe82ee64f09'
    create_table :deep_import_parents do |t|
      t.string :deep_import_id, references: false
      t.datetime :parsed_at
      t.timestamps
    end
    create_table :deep_import_children do |t|
      t.string :deep_import_id, references: false
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_parent_id, references: false
    end
    add_index :deep_import_children, [:deep_import_id, :deep_import_parent_id], name: 'di_parent_5398201a25d34aa77ba2aad1ab1114c6'
    create_table :deep_import_grand_children do |t|
      t.string :deep_import_id, references: false
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_child_id, references: false
    end
    add_index :deep_import_grand_children, [:deep_import_id, :deep_import_child_id], name: 'di_child_68c870732d51b24b0fa476536d9b20d4'
    create_table :deep_import_in_laws do |t|
      t.string :deep_import_id, references: false
      t.datetime :parsed_at
      t.timestamps
      t.string :deep_import_relation_id, references: false
      t.string :deep_import_relation_type, references: false
    end
    add_index :deep_import_in_laws, [:deep_import_id, :deep_import_relation_type, :deep_import_relation_id], name: 'di_relation_9adaf4e4e674802642cc46939a5f06f7'
    add_index :deep_import_in_laws, [:deep_import_relation_type], name: 'di_relation_9adaf4e4e674802642cc46939a5f06f7_type'
  end
end
