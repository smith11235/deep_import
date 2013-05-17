class AddDeepImportBelongsToIndiciesToDeepImportGrandChildren < ActiveRecord::Migration
  def change
      add_index :deep_import_grand_children, [:deep_import_id, :deep_import_child_id], :name => 'di_child'
  end
end
