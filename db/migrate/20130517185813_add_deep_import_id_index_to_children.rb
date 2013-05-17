class AddDeepImportIdIndexToChildren < ActiveRecord::Migration
  def change
      add_index :children, [:deep_import_id, :id], :name => 'di_id_index'
  end
end
