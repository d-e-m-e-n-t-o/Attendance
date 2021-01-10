class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :remember_digest
      t.boolean :admin, default: false
      t.boolean :superior, default: false
      t.string :affiliation
      t.datetime :basic_work_time, default: Time.current.change(hour: 7, min: 0, sec: 0)
      t.datetime :designated_work_start_time, default: Time.current.change(hour: 9, min: 0, sec: 0)
      t.datetime :designated_work_end_time, default: Time.current.change(hour: 17, min: 0, sec: 0)
      t.string :employee_number
      t.string :uid

      t.timestamps
    end
  end
end
