class CreateMonthapplies < ActiveRecord::Migration[5.1]
  def change
    create_table :monthapplies do |t|
      t.date :month_first_day
      t.integer :month_request_superior
      t.string :month_request_status, default: "なし"
      t.boolean :month_check_confirm
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
