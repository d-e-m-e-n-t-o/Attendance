class RenameScheduledEndTimeColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :Scheduled_end_time, :scheduled_end_time
  end
end
