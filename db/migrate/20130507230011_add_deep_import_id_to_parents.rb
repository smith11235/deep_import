class AddDeepImportIdToParents < ActiveRecord::Migration
  def change
    add_column :parents, :deep_import_id, :string
  end
end
