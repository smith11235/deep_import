class AddNameToDummyModels < ActiveRecord::Migration
  def change
    add_column :dummy_models, :name, :string
  end
end
