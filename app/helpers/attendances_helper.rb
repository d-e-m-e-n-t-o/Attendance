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
    spe_time = format("%.2f", (((finish - start) / 60) / 60.0))
    start < finish ? spe_time : format("%.2f",spe_time.to_f + 24)
  end
  
  # 勤怠変更申請の出勤時間と退勤時間を比較検証。(minも考慮しTod::TimeOfDayで時刻にパースする。)
  def compare_verify_edit_apply_time?(id, start, finish, check)
    attendance = Attendance.find(id)
    sta_at = Tod::TimeOfDay.parsable?(start) ? start : format("%.2d", attendance.edit_day_started_at.hour) + ":" + format("%.2d", attendance.edit_day_started_at.min)
    fin_at = Tod::TimeOfDay.parsable?(finish) ? finish : format("%.2d", attendance.edit_day_finished_at.hour) + ":" + format("%.2d", attendance.edit_day_finished_at.min)
    if check == "0"
      Tod::TimeOfDay.parse(sta_at) > Tod::TimeOfDay.parse(fin_at) || Tod::TimeOfDay.parse(sta_at) == Tod::TimeOfDay.parse(fin_at)
    elsif check == "1"
      Tod::TimeOfDay.parse(sta_at) < Tod::TimeOfDay.parse(fin_at)
    end
  end
  
    # 残業申請の終了予定時間と退勤時間を比較検証。
  def compare_verify_over_apply_time?(id, over, check)
    attendance = Attendance.find(id)
    user = User.find_by(id: attendance[:user_id])
    fin_time = attendance.finished_at.nil? ? format("%.2d", user.designated_work_end_time.hour) + ":" + format("%.2d", user.designated_work_end_time.min) : attendance.finished_at
    fin_at = Tod::TimeOfDay.parsable?(fin_time) ? fin_time : format("%.2d", attendance.finished_at.hour) + ":" + format("%.2d", attendance.finished_at.min)
    ove_at = Tod::TimeOfDay.parsable?(over) ? over : format("%.2d", attendance.over_end_at.hour) + ":" + format("%.2d", attendance.over_end_at.min)
    if check == "0"
      Tod::TimeOfDay.parse(fin_at) > Tod::TimeOfDay.parse(ove_at) || Tod::TimeOfDay.parse(fin_at) == Tod::TimeOfDay.parse(ove_at)
    elsif check == "1"
      Tod::TimeOfDay.parse(fin_at) < Tod::TimeOfDay.parse(ove_at)
    end
  end
  
  # 時間外時間を計算
  def over_times(id, over, finish, check)
    attendance = Attendance.find(id)
    finish = finish.nil? && attendance.edit_day_request_status == "承認" ? attendance.edit_day_finished_at : finish
    finish = finish.nil? ? @user.designated_work_end_time : finish
    ove_time = format("%.2f", ((((over.hour - finish.hour) * 60) + (over.min - finish.min)) / 60.0))
    check == false ?  ove_time : format("%.2f",ove_time.to_f + 24)
  end
end