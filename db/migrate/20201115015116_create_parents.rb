class CreateParents < ActiveRecord::Migration[5.2]
  def change
    create_table :parents do |t|
      t.string :name
      t.json :data

      t.timestamps
    end
  end
end
