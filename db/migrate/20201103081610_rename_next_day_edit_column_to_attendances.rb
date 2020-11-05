class RenameNextDayEditColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :next_day_edit, :check_edit_one_month
  end
end
