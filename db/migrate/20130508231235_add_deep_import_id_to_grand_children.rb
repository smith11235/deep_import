class AddDeepImportIdToGrandChildren < ActiveRecord::Migration
  def change
    add_column :grand_children, :deep_import_id, :string
  end
end
