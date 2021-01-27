class AddEditdaysToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_day_started_at, :datetime
    add_column :attendances, :edit_day_finished_at, :datetime
    add_column :attendances, :edit_next_day, :boolean
    add_column :attendances, :day_note, :string
    add_column :attendances, :edit_day_request_superior, :integer
    add_column :attendances, :edit_day_request_status, :string, default: 'なし'
    add_column :attendances, :edit_day_check_confirm, :boolean
  end
end
