class RenameNextDayOvertimeColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :next_day_overtime, :check_overtime_apply
  end
end
