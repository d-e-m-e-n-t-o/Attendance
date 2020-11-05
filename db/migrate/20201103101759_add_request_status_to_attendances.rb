class AddRequestStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :request_status, :string
  end
end
