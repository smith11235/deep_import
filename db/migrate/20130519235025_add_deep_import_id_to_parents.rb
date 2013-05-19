class AddDeepImportIdToParents < ActiveRecord::Migration
  def change
    add_column :parents, :deep_import_id, :string
    add_index :parents, [:deep_import_id, :id], :name => 'di_id_index'
  end
end
