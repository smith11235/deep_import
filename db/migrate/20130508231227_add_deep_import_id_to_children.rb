class AddDeepImportIdToChildren < ActiveRecord::Migration
  def change
    add_column :children, :deep_import_id, :string
  end
end
