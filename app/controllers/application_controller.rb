class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include AttendancesHelper

  def set_one_month
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date # 対象月の初日を取得
    @last_day = @first_day.end_of_month # 対象月の終日を取得
    one_month = [*@first_day..@last_day] # 1ヶ月分のオブジェクトが代入された配列を定義
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    @attendances.each do |attendanc|
      if Date.current > attendanc[:worked_on] && attendanc[:edit_day_request_status] == '承認'
        attendanc.update(started_at: attendanc.edit_day_started_at, finished_at: attendanc.edit_day_finished_at)
      end
    end
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do # トランザクションを開始
        one_month.each { |day| @user.attendances.create!(worked_on: day) } # 繰り返し処理により、1ヶ月分の勤怠データを生成
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
    unless Monthapply.exists?(month_first_day: @first_day, user_id: @user.id)
      @user.monthapplies.build(month_first_day: @first_day).save
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐
    flash[:danger] = 'ページ情報の取得に失敗しました、再アクセスしてください。'
    redirect_to root_url
  end

  # ↓ before_action_filter ↓
  def set_user_id
    @user = User.find(params[:id])
  end

  def set_user_user_id
    @user = User.find(params[:user_id])
  end

  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  # ユーザーがログイン済みか確認
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'ログインしてください。'
    redirect_to login_url
  end

  # 管理権限者、または現在ログインしているユーザーを許可
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
  end

  # 管理権限者以外を許可
  def superior_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
    return unless current_user.admin?

    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
  end

  # アクセスしたユーザーが現在ログイン中か確認
  def correct_user
    return if current_user?(@user)

    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
  end

  # 管理権限者を許可
  def admin_user
    return if current_user.admin?

    flash[:danger] = '編集権限がありません。'
    redirect_to root_url
  end

  # 上長権限者を許可
  def superior_user
    return if current_user.superior?

    flash[:danger] = '編集権限がありません。'
    redirect_to root_url
  end
end
