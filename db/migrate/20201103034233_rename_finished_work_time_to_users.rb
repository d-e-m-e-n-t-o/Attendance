class RenameFinishedWorkTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :finished_work_time, :designated_work_end_time
  end
end
