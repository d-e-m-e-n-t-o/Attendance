class AddOvertimesToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :over_end_at, :datetime
    add_column :attendances, :over_next_day, :boolean
    add_column :attendances, :over_note, :string
    add_column :attendances, :over_request_superior, :integer
    add_column :attendances, :over_request_status, :string, default: 'なし'
    add_column :attendances, :over_check_confirm, :boolean
  end
end
