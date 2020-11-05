class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  # 当日より以前の日付を編集する場合、出勤時間のみは無効
  validate :edit_attendance_before_the_day_only_started_at_is_invalid
  
  def edit_attendance_before_the_day_only_started_at_is_invalid
    if Date.current > worked_on
      errors.add(:finished_at, "が必要です") if started_at.present? && finished_at.blank?
    end
  end
  
  # 残業を申請する場合、終了予定時間、業務処理内容、指示書確認㊞すべて必要
  validate :required_items_for_overtime_apply
  
  def required_items_for_overtime_apply
    if scheduled_end_time.present? || business_content.present? || directions.present?
      errors.add(:scheduled_end_time, "、業務処理内容、指示書確認㊞、の全てが必要です。") if scheduled_end_time.blank? || business_content.blank? || directions.blank?
    end
  end
  
  # 日を跨いだ残業申請をする場合、翌日にチェックが必要
  validate :next_day_business_end_check_required
  
  def next_day_business_end_check_required
    if check_overtime_apply == "0" && scheduled_end_time.present?
      errors.add(:check_overtime_apply, "にチェックが必要です") if finished_at > scheduled_end_time
    end
  end
end
