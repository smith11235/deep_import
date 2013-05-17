class AddDeepImportIdIndexToParents < ActiveRecord::Migration
  def change
      add_index :parents, [:deep_import_id, :id], :name => 'di_id_index'
  end
end
