class CreateGrandChildren < ActiveRecord::Migration
  def change
    create_table :grand_children do |t|
      t.references :child
      t.string :name

      t.timestamps
    end
    add_index :grand_children, :child_id
  end
end
