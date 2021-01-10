class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :day_note, length: { maximum: 50 }
  
# ↓ edit_day_apply_validates ↓
  # 勤怠変更を申請する場合、出勤時間、退勤時間、変更理由、指示書確認㊞のすべてが必要
  validate :edit_day_apply_items_for_required
  
  def edit_day_apply_items_for_required
    if edit_day_started_at.blank? || edit_day_finished_at.blank? ||  edit_day_request_superior.blank?
       errors.add(:edit_day_started_at, "、退勤時間、指示書確認㊞の全てが入力されていない申請があります。") if edit_day_request_status == "申請中"
    end
  end
  
  # 勤怠変更を申請中のみでの申請は無効
  validate :edit_day_only_applying_invalid
  
  def edit_day_only_applying_invalid
    if edit_day_started_at.blank? && edit_day_finished_at.blank? && edit_day_request_superior.blank?
      errors.add(:edit_day_started_at,"、退勤時間、指示書確認㊞を入力し申請してください。") if edit_day_request_status == "申請中"
    end
  end
  
  # 日を跨いだ勤怠変更を申請する場合、翌日にチェックが必要
  validate :edit_day_finished_at_next_end_check_required
  
  def edit_day_finished_at_next_end_check_required
    if edit_day_request_status == "申請中" && edit_day_started_at.present? && edit_day_finished_at.present? && edit_day_request_superior.present? && edit_next_day == false
      errors.add(:edit_next_day, "のチェックが不要、または必要な申請があります。") if edit_day_started_at > edit_day_finished_at || edit_day_started_at == edit_day_finished_at
    end
  end
  
  # 日を跨がない勤怠変更を申請する場合、翌日のチェックは不要
  validate :edit_day_finished_at_not_next_end_not_check_required
  
  def edit_day_finished_at_not_next_end_not_check_required
    if edit_day_request_status == "申請中" && edit_day_started_at.present? && edit_day_finished_at.present? && edit_day_request_superior.present? && edit_next_day == true
      errors.add(:edit_next_day, "のチェックが不要、または必要な申請があります。") if edit_day_started_at < edit_day_finished_at
    end
  end
  
# ↓ update_edit_day_request_status_validates ↓
  # 申請中を変更する場合、指示書確認㊞が必要
  validates :edit_day_request_status, presence: { message: "が選択されていない申請があります。" }
  
  # 申請中を変更する場合、チェックが必要
  validate :change_edit_day_apllying_check_required
  
  def change_edit_day_apllying_check_required
    if edit_day_check_confirm == false && edit_day_request_status != "申請中"
      errors.add(:edit_day_check_confirm, "のチェックがされていない申請があります。")
    end
  end
  
# ↓ over_apply_validates ↓
  # 残業を申請する場合、終了予定時間、業務処理内容、指示書確認㊞すべてが必要
  validate :over_apply_items_for_required
  
  def over_apply_items_for_required
    if over_end_at.blank? || over_request_superior.blank? || over_request_status.blank?
      errors.add(:over_end_at, "、指示書確認㊞の全てが必要です。") if over_request_status == "申請中"
    end
  end
  
  # 残業を申請中のみでの申請は無効
  validate :over_only_applying_invalid
  
  def over_only_applying_invalid
    if over_request_status == "申請中" && over_end_at.blank? && over_request_superior.blank?
      errors.add(:over_end_at,"、退勤時間、指示書確認㊞を入力し申請してください。")
    end
  end
  
  # 残業申請をする場合の時間比較と翌日チェックを検証(finished_atが空でedit_day_request_statusが承認以外)
  validate :over_apply_compare_verify_time_check_finished_at_nil_edit_day_request_status_other_than_approval
  
  def over_apply_compare_verify_time_check_finished_at_nil_edit_day_request_status_other_than_approval
    if over_request_status == "申請中" && over_end_at.present? && over_request_superior.present? && finished_at.nil? && edit_day_request_status != "承認"
      user = User.find(user_id)
      if over_next_day == false
        errors.add(:over_next_day, "のチェックが不要、または必要な申請があります。") if user.designated_work_end_time.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) > over_end_at || user.designated_work_end_time.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) == over_end_at
      elsif over_next_day == true
        errors.add(:over_next_day, "のチェックが不要、または必要な申請があります。") if user.designated_work_end_time.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) < over_end_at
      end
    end
  end
  
  # 残業申請をする場合の時間比較と翌日チェックを検証(finished_atが空でedit_day_request_statusが承認)
  validate :over_apply_compare_verify_time_check_finished_at_nil_edit_day_request_status_approval
  
  def over_apply_compare_verify_time_check_finished_at_nil_edit_day_request_status_approval
    if over_request_status == "申請中" && over_end_at.present? && over_request_superior.present? && finished_at.nil? && edit_day_request_status == "承認"
      if over_next_day == false
        errors.add(:over_next_day, "のチェックが不要、または必要な申請があります。") if edit_day_finished_at.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) > over_end_at || edit_day_finished_at.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) == over_end_at
      elsif over_next_day == true
        errors.add(:over_next_day, "のチェックが不要、または必要な申請があります。") if edit_day_finished_at.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) < over_end_at
      end
    end
  end
  
  # 残業申請をする場合の時間比較と翌日チェックを検証(finished_atが存在)
  validate :over_apply_compare_verify_time_check_finished_at_present
  
  def over_apply_compare_verify_time_check_finished_at_present
    if over_request_status == "申請中" && over_end_at.present? && over_request_superior.present? && finished_at.present?
      if over_next_day == false
        errors.add(:over_next_day, "のチェックが不要、または必要な申請があります。") if finished_at.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) > over_end_at || finished_at.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) == over_end_at
      end
      if over_next_day == true
        errors.add(:over_next_day, "のチェックが不要、または必要な申請があります。") if finished_at.change(year:Date.current.year, month:Date.current.month, day:Date.current.day) < over_end_at
      end
    end
  end
  
# ↓ update_over_request_status_validates ↓
  # 申請中を変更する場合、指示書確認㊞が必要
  validates :over_request_status, presence: { message: "が選択されていない申請があります。" }
  
  # 申請中を変更する場合、チェックが必要
  validate :change_over_apllying_check_required
  
  def change_over_apllying_check_required
    if over_check_confirm == false && over_request_status != "申請中"
      errors.add(:over_check_confirm, "のチェックがされていない申請があります。")
    end
  end
end
