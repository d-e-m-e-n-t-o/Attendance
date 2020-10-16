class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  def set_one_month
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date # 対象月の初日を取得
    @last_day = @first_day.end_of_month # 対象月の終日を取得
    one_month = [*@first_day..@last_day] # 1ヶ月分のオブジェクトが代入された配列を定義
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do # トランザクションを開始
        one_month.each { |day| @user.attendances.create!(worked_on: day) } # 繰り返し処理により、1ヶ月分の勤怠データを生成
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end
