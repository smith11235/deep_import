class AddDeepImportIdToGrandChildren < ActiveRecord::Migration
  def change
    add_column :grand_children, :deep_import_id, :string
    add_index :grand_children, [:deep_import_id, :id], :name => 'di_id_index'
  end
end
