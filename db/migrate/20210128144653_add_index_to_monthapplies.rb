class AddIndexToMonthapplies < ActiveRecord::Migration[6.0]
  def change
    add_index :monthapplies, [:month_first_day, :user_id], unique: true
  end
end
