class AddAttendanceApprovedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_approved, :string
  end
end
