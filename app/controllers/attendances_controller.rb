class AttendancesController < ApplicationController
  before_action :set_user_id, only: [:edit_days_apply, :update_edit_days_apply, :edit_days_applying, :over_applying, :update_over_applyin, :attendances_applying_update_index, :approval_log]
  before_action :set_user_user_id, only: [:update, :destroy_edit_days_apply, :edit_day_reapply, :over_apply, :update_over_apply, :destroy_over_apply, :index]
  before_action :set_attendance, only: [:update, :destroy_edit_days_apply, :edit_day_reapply, :over_apply, :update_over_apply, :destroy_over_apply]
  before_action :logged_in_user, only: [:update, :edit_days_apply]
  before_action :set_one_month, only: [:edit_days_apply, :index, :approval_log]
  before_action :admin_or_correct_user, only: [:update, :edit_days_apply, :update_edit_days_apply]

# ↓ 出勤登録 ↓
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
  
# ↓ 勤怠変更申請 ↓
  def edit_days_apply
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_edit_days_apply
    edit_days_apply_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:edit_day_started_at].blank? && item[:edit_day_finished_at].blank? && item[:day_note].blank? && item[:edit_day_request_superior].blank?
        flash[:info] = "出勤時間、退勤時間、変更理由、指示書確認㊞を入力し申請してください。" if item[:edit_day_request_status] == "申請中" && flash[:danger].blank? && flash[:warning].blank? && flash[:success].blank?
      elsif item[:edit_day_started_at].blank? || item[:edit_day_finished_at].blank? || item[:day_note].blank? || item[:edit_day_request_superior].blank?
        flash.delete(:info)
        flash.delete(:success)
        flash[:danger] = "#{l(attendance.worked_on, format: :long)}の勤怠変更申請は失敗しました。出勤時間 、退勤時間、変更理由、指示書確認㊞の全てが必要です。" if item[:edit_day_request_status] == "申請中"
      end
      if item[:edit_day_started_at].present? && item[:edit_day_finished_at].present? && item[:day_note].present? && item[:edit_day_request_superior].present?
        if compare_verify_edit_apply_time?(id, item[:edit_day_started_at], item[:edit_day_finished_at], item[:edit_next_day])
          flash.delete(:info)
          flash.delete(:success)
          flash[:warning] = "#{l(attendance.worked_on, format: :long)}の勤怠変更申請は失敗しました。翌日のチェックが必要です。"  if item[:edit_day_request_status] == "申請中" &&  item[:edit_next_day] == "0"
          flash[:warning] = "#{l(attendance.worked_on, format: :long)}の勤怠変更申請は失敗しました。翌日のチェックが不要です。"  if item[:edit_day_request_status] == "申請中" &&  item[:edit_next_day] == "1"
        elsif attendance.update_attributes(item)
          flash.delete(:info)
          flash[:success] = "勤怠変更を申請しました。" if item[:edit_day_request_status] == "申請中" && flash[:danger].blank? && flash[:warning].blank?
        end
      end
      if attendance.started_at.present? && attendance.finished_at.present? && attendance.before_started_at.blank? && attendance.before_finished_at.blank?
        attendance.update_attributes(before_started_at: attendance.started_at, before_finished_at: attendance.finished_at)
      end
    end
    redirect_to attendances_edit_days_apply_user_path(@user, date: params[:date])
  end
  
  def destroy_edit_days_apply
    if @attendance.edit_day_request_status == "申請中"
      @attendance.update_attributes(edit_day_started_at: nil, edit_day_finished_at: nil, edit_next_day: nil, day_note: nil, edit_day_request_superior: nil, edit_day_request_status: "なし", edit_day_check_confirm: nil)
      flash[:success] = "勤怠変更申請を取り消しました。"
    else
      flash[:danger] = "上長より申請が取り消されました。" if @attendance.edit_day_request_status == "なし"
      flash[:danger] = "上長より#{@attendance.edit_day_request_status}されたため、申請取消に失敗しました。"
    end
      redirect_to attendances_edit_days_apply_user_path(@user, date: params[:date])
  end
  
  def edit_day_reapply
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @first_day = params[:date]
  end

# ↓ 勤怠申請承認 ↓
  def edit_days_applying
    @edit_days_applying = Attendance.where(edit_day_request_superior: @user.id, edit_day_request_status: "申請中").order(:user_id).group_by(&:user_id)
    @first_day = params[:date]
  end
  
  def update_edit_days_applying
    update_edit_days_applying_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:edit_day_request_status].present? && item[:edit_day_request_status] != "申請中" && item[:edit_day_check_confirm] == "1"
        attendance.update_attributes(edit_day_started_at: nil, edit_day_finished_at: nil, edit_next_day: nil, day_note: nil, edit_day_request_status: "なし", edit_day_check_confirm: "1") if item[:edit_day_request_status] == "なし"
        attendance.update_attributes(item)
        flash.delete(:info)
        flash[:success] = "勤怠の申請状態を変更しました。"
      elsif item[:edit_day_request_status].blank? && item[:edit_day_check_confirm] == "0"
        flash[:info] = "申請状態を変更するには、指示書確認㊞と変更欄のチェックが必要です。" if flash[:danger].blank? && flash[:warning].blank? && flash[:success].blank?
      else
        flash[:danger] = "#{l(attendance.worked_on, format: :long)}の申請状態変更に失敗しました。指示者確認㊞が必要です。" if item[:edit_day_request_status].blank? && item[:edit_day_check_confirm] == "1"
        flash[:warning] = "#{l(attendance.worked_on, format: :long)}の申請状態変更に失敗しました。変更欄のチェックが必要です。" if item[:edit_day_request_status] != "申請中" && item[:edit_day_check_confirm] == "0"
        flash.delete(:info) if flash[:danger].present? || flash[:warning].present?
        flash.delete(:success) if flash[:danger].present? || flash[:warning].present?
      end
      
      
      
    end
    redirect_to user_url(date: params[:date])
  end
  
# ↓ 残業申請 ↓
  def over_apply
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_over_apply
    @first_day = @attendance.worked_on.beginning_of_month
    if over_params[:over_end_at].blank? && over_params[:over_note].blank? && over_params[:over_request_superior].blank?
      flash[:info] = "終了予定時間、業務処理内容、指示書確認㊞を入力し申請してください。" if over_params[:over_request_status] == "申請中" && flash[:danger].blank? && flash[:warning].blank? && flash[:success].blank?
    elsif over_params[:over_end_at].blank? || over_params[:over_note].blank? || over_params[:over_request_superior].blank?
      flash.delete(:info)
      flash.delete(:success)
      flash[:danger] = "#{l(@attendance.worked_on, format: :long)}の残業申請に失敗しました。終了予定時間、業務処理内容、指示書確認㊞、の全てが必要です。" if over_params[:over_request_status] == "申請中"
    end
    if over_params[:over_end_at].present? && over_params[:over_note].present? && over_params[:over_request_superior].present?
      if compare_verify_over_apply_time?(params[:id], over_params[:over_end_at], over_params[:over_next_day])
        flash.delete(:info)
        flash.delete(:success)
        flash[:warning] = "#{l(@attendance.worked_on, format: :long)}の残業申請に失敗しました。翌日のチェックが必要です。" if over_params[:over_request_status] == "申請中" && over_params[:over_next_day] == "0"
        flash[:warning] = "#{l(@attendance.worked_on, format: :long)}の残業申請に失敗しました。翌日のチェックが不要です。" if over_params[:over_request_status] == "申請中" && over_params[:over_next_day] == "1"
      elsif @attendance.update_attributes(over_params)
        flash.delete(:info)
        flash[:success] = "残業を申請しました。" if over_params[:over_request_status] == "申請中" && flash[:danger].blank? && flash[:warning].blank?
      end
    end
    redirect_to user_url(@user, date: params[:date])
  end
  
  def destroy_over_apply
    if @attendance.over_request_status == "申請中"
      @attendance.update_attributes(over_end_at: nil, over_next_day: nil, over_note: nil, over_request_superior: nil, over_request_status: "なし", over_check_confirm: nil)
      flash[:success] = "勤怠変更申請を取り消しました。"
    else
      flash[:danger] = "上長より申請が取り消されました。" if @attendance.over_request_status == "なし"
      flash[:danger] = "上長より#{@attendance.over_request_status}されたため、申請取消に失敗しました。"
    end
    redirect_to user_url(@user, date: params[:date])
  end
  
# ↓ 残業申請承認 ↓
  def over_applying
    @over_applying = Attendance.where(over_request_superior: @user.id, over_request_status: "申請中").order(:user_id).group_by(&:user_id)
    @first_day = params[:date]
  end
  
  def update_over_applying
    update_over_applying_params.each do |id, item|
    attendance = Attendance.find(id)
      if item[:over_request_status].present? && item[:over_request_status] != "申請中" && item[:over_check_confirm] == "1"
        attendance.update_attributes(over_end_at: nil, over_next_day: nil, over_note: nil, over_request_status: "なし", over_check_confirm: "1") if item[:over_request_status] == "なし"
        attendance.update_attributes(item)
        flash.delete(:info)
        flash[:success] = "勤怠の申請状態を変更しました。"
      elsif item[:over_request_status].blank? && item[:over_check_confirm] == "0"
        flash[:info] = "申請状態を変更するには、指示書確認㊞と変更欄のチェックが必要です。" if flash[:danger].blank? && flash[:warning].blank? && flash[:success].blank?
      else
        flash[:danger] = "#{l(attendance.worked_on, format: :long)}の申請状態変更に失敗しました。指示者確認㊞が必要です。" if item[:over_request_status].blank? && item[:over_check_confirm] == "1"
        flash[:warning] = "#{l(attendance.worked_on, format: :long)}の申請状態変更に失敗しました。変更欄のチェックが必要です。" if item[:over_request_status] != "申請中" && item[:over_check_confirm] == "0"
        flash.delete(:info) if flash[:danger].present? || flash[:warning].present?
        flash.delete(:success) if flash[:danger].present? || flash[:warning].present?
      end
    end
    redirect_to user_url(date: params[:date])
  end
  
# ↓ 各種申請承認一覧↓
  def attendances_applying_update_index
    @first_day = Date.current.beginning_of_month
    @monthapplies_update_applying = @user.monthapplies.where(month_check_confirm: true)
    @edit_day_update_applying = @user.attendances.where(edit_day_check_confirm: true)
    @over_update_applying = @user.attendances.where(over_check_confirm: true)
    @monthapplies_update_applying.update(month_check_confirm: nil)
    @edit_day_update_applying.update(edit_day_check_confirm: nil)
    @over_update_applying.update(over_check_confirm: nil)
  end

# ↓ CSV出力 ↓
  def index
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(@attendances)
      end
    end
  end

# ↓ 勤怠ログ ↓
  def approval_log
    @approved_attendances = @attendances.where("(edit_day_request_status = ?) OR (over_request_status = ?)", "承認", "承認")
    approved_attendances = @user.attendances.where("(edit_day_request_status = ?) OR (over_request_status = ?)", "承認", "承認")
    @year = approved_attendances.pluck(:worked_on).map{|day| day.year}.uniq
    @month = approved_attendances.pluck(:worked_on).map{|day| day.month}.uniq
  end
  
  private
  
    # 勤怠変更申請
    def edit_days_apply_params
      params.require(:user).permit(attendances: [:edit_day_started_at, :edit_day_finished_at, :edit_next_day, :day_note, :edit_day_request_superior,
      :edit_day_request_status, :edit_day_check_confirm])[:attendances]
    end
    
    # 勤怠申請承認
    def update_edit_days_applying_params
      params.require(:user).permit(applying_update_edit_days: [:edit_day_request_status, :edit_day_check_confirm])[:applying_update_edit_days]
    end
    
    # 残業申請
    def over_params
      params.require(:user).permit(attendances: [:over_end_at, :over_next_day, :over_note, :over_request_superior,
      :over_request_status, :over_check_confirm])[:attendances]
    end
    
    # 残業申請承認
    def update_over_applying_params
      params.require(:user).permit(applying_update_over: [:over_request_status, :over_check_confirm])[:applying_update_over]
    end
    
    # csv出力
    def send_posts_csv(attendances)
      title_date = attendances.first[:worked_on]
      csv_data = CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
        column_names = %w(日付 曜日 出社 退社)
        csv << column_names
          attendances.each do |attendance|
          column_values = [
          l(attendance.worked_on, format: :short),
          $days_of_the_week[attendance.worked_on.wday],
          l(attendance.started_at, format: :time, default: ' ') ,
          l(attendance.finished_at, format: :time, default: ' ') ,
          ]
          csv << column_values
          end
      end
      send_data(csv_data, filename: "#{l(title_date, format: :middle)} 勤怠表.csv")
    end
end