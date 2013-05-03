class CreateDummyModels < ActiveRecord::Migration
  def change
    create_table :dummy_models do |t|
      t.references :dummy_model

      t.timestamps
    end
    add_index :dummy_models, :dummy_model_id
  end
end
