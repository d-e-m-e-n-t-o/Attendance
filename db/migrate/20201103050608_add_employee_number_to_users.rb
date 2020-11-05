class AddEmployeeNumberToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :string
    add_column :users, :uid, :string
  end
end
