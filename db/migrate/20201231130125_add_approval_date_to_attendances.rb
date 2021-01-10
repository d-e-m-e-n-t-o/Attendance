class AddApprovalDateToAttendances < ActiveRecord::Migration[6.0]
  def change
    add_column :attendances, :edit_approval_day, :date
    add_column :attendances, :over_approval_day, :date
  end
end
