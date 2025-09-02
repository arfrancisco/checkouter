class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :code, null: false
      t.string :name
      t.text :description
      t.integer :price

      t.timestamps
    end
  end
end
