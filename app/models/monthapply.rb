class Monthapply < ApplicationRecord
  belongs_to :user
  
# ↓ month_apply_validates ↓
  validates :month_first_day, presence: true, uniqueness: { scope: :user_id }

# ↓ change_month_request_status_validates ↓

  # 申請中を変更する場合、指示書確認㊞が必要
  validates :month_request_status, presence: { message: "が選択されていない月があります。" }
  
  # 申請中を変更する場合、チェックが必要
  validate :change_month_apllying_check_required
  
  def change_month_apllying_check_required
    if month_check_confirm == false && month_request_status != "申請中"
      errors.add(:month_check_confirm, "のチェックがされていない月があります。")
    end
  end
  
end
