module BasesHelper
  def base_state(base)
    return '出勤' if base.type.blank? || base.type == '退勤'
    return '退勤' if base.type == '出勤'
  end
end
