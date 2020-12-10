class CreateInLaws < ActiveRecord::Migration[5.2]
  def change
    create_table :in_laws do |t|
      t.string :name
      t.json :data
      t.references :relation, polymorphic: true, index: true

      t.timestamps
    end
  end
end
