class AddPromosToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :applicable_promos, :text, array: true, default: []
  end
end
