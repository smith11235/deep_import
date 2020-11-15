class CreateGrandChildren < ActiveRecord::Migration[5.2]
  def change
    create_table :grand_children do |t|
      t.string :name
      t.references :child, foreign_key: true
      t.json :data

      t.timestamps
    end
  end
end
