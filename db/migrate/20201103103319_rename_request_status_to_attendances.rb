class RenameRequestStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :request_status, :month_request_status
  end
end
