module AttendancesHelper
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  # 在社時間を計算(時間オブジェクトの計算結果は秒数となる。)
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  # 時間外時間を計算
  def over_times(scheduled_end, finished, next_day)
    overtimes = format("%.2f", ((((scheduled_end.hour - finished.hour) * 60) + (scheduled_end.min - finished.min)) / 60.0))
    next_day == "0" ?  overtimes : format("%.2f",overtimes.to_f + 24)
  end
end