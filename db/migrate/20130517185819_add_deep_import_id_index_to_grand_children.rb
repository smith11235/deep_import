class AddDeepImportIdIndexToGrandChildren < ActiveRecord::Migration
  def change
      add_index :grand_children, [:deep_import_id, :id], :name => 'di_id_index'
  end
end
