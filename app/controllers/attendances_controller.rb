class AttendancesController < ApplicationController
  before_action :set_user_id, only: [:edit_one_month, :update_one_month]
  before_action :set_user_user_id, only: [:update, :overtime_apply, :update_overtime_apply, :apply_one_month]
  before_action :set_attendance, only: [:update, :overtime_apply, :update_overtime_apply]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :set_one_month, only: [:edit_one_month, :apply_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:started_at].blank? && item[:finished_at].present?
          flash[:danger] = "出勤時間が必要です。"
        elsif item[:started_at] > item[:finished_at] && item[:started_at].present? && item[:finished_at].present?
          flash[:danger] = "出勤時間より早い退勤時間は無効です。"
        elsif Date.current > attendance.worked_on && item[:started_at].present? && item[:finished_at].blank?
          flash[:danger] = "退勤時間が必要です。"
        end
          attendance.update_attributes!(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def overtime_apply
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_overtime_apply
    @first_day = @attendance.worked_on.beginning_of_month
      if overtime_params[:scheduled_end_time].blank? || overtime_params[:business_content].blank? || overtime_params[:directions].blank?
        flash[:danger] = "終了予定時間、業務処理内容、指示書確認㊞、の全てが必要です。"
        redirect_to user_url( @user)
      elsif overtime_params[:check_overtime_apply] == "0" && @attendance[:finished_at].hour > overtime_params[:scheduled_end_time].to_i
        flash[:danger] = "終了予定時間が翌日の場合、チェックが必要です。"
        redirect_to user_url( @user)
      else @attendance.update_attributes!(overtime_params)
        flash[:success] = "残業申請を入力しました。"
        redirect_to user_url(@user, date: @first_day)
      end
  rescue ActiveRecord::RecordInvalid
    redirect_to user_url(@user, date: @first_day)
  end
  
  def apply_one_month
    if @attendances.update(apply_params)
      flash[:success] = "1ヶ月分の勤怠情報を申請しました。"
    else
      flash[:danger] = "1ヶ月分の勤怠情報申請に失敗しました。"
    end
      redirect_to user_url(@user, date: @first_day)
  end

  private
   
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def overtime_params
      params.require(:user).permit(attendances: [:scheduled_end_time, :check_overtime_apply, :business_content, :directions])[:attendances]
    end
end
