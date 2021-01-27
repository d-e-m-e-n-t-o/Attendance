module UsersHelper
  # 勤怠基本情報時間を指定のフォーマットで返す。
  def format_basic_info(time)
    format('%.2f', ((time.hour * 60) + time.min) / 60.0)
  end

  # 残業時間計算
  def cumulative_overtime(time_array)
    time_array.each do |time|
      time_sum.to_f += ((time.hour * 60) + time.min)
    end
    format('%.2f', (time_sum / 60.0))
  end
end
