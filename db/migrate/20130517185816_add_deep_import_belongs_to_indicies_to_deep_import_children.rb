class AddDeepImportBelongsToIndiciesToDeepImportChildren < ActiveRecord::Migration
  def change
      add_index :deep_import_children, [:deep_import_id, :deep_import_parent_id], :name => 'di_parent'
  end
end
