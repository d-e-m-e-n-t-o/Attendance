# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_31_130125) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "edit_day_started_at"
    t.datetime "edit_day_finished_at"
    t.boolean "edit_next_day"
    t.string "day_note"
    t.integer "edit_day_request_superior"
    t.string "edit_day_request_status", default: "なし"
    t.boolean "edit_day_check_confirm"
    t.datetime "over_end_at"
    t.boolean "over_next_day"
    t.string "over_note"
    t.integer "over_request_superior"
    t.string "over_request_status", default: "なし"
    t.boolean "over_check_confirm"
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.date "edit_approval_day"
    t.date "over_approval_day"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthapplies", force: :cascade do |t|
    t.date "month_first_day"
    t.integer "month_request_superior"
    t.string "month_request_status", default: "なし"
    t.boolean "month_check_confirm"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_monthapplies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.boolean "superior", default: false
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2021-01-06 22:00:00"
    t.datetime "designated_work_start_time", default: "2021-01-07 00:00:00"
    t.datetime "designated_work_end_time", default: "2021-01-07 08:00:00"
    t.string "employee_number"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "attendances", "users"
  add_foreign_key "monthapplies", "users"
end
