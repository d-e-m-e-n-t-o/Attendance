class Monthapply < ApplicationRecord
  belongs_to :user
  
  validates :month_first_day, presence: true, uniqueness: { scope: :user_id }
  validates :month_request_status, presence: true
  validates :month_request_superior, presence: true, on: :update
  
  # 申請中を変更する場合、チェックが必要
  validate :aplly_approval_check_required
  
  def aplly_approval_check_required
    if month_check_confirm == false && month_request_status != "申請中"
      errors.add(:month_check_confirm, "にチェックが必要です。")
    end
  end
end
