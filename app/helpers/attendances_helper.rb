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
end
