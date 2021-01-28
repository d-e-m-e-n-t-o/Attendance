class AddIndexToBases < ActiveRecord::Migration[6.0]
  def change
    add_index :bases, :number, unique: true
    add_index :bases, :name, unique: true
  end
end
