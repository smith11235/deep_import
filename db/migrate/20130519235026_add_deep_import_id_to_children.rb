class AddDeepImportIdToChildren < ActiveRecord::Migration
  def change
    add_column :children, :deep_import_id, :string
    add_index :children, [:deep_import_id, :id], :name => 'di_id_index'
  end
end
