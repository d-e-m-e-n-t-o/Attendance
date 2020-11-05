class AddOvertimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime, :datetime
    add_column :attendances, :business_content, :string
    add_column :attendances, :directions, :string
  end
end
