class AddNextDayOvertimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :next_day_overtime, :string
    add_column :attendances, :next_day_edit, :string
  end
end
