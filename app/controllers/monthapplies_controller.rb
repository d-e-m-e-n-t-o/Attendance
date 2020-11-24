class MonthappliesController < ApplicationController
  before_action :set_user_user_id, only: [:update, :destroy, :edit, :show]
  before_action :set_applying_month, only: [:update, :destroy]
  before_action :set_one_month, only: :show
  
  def update
    @applying_month = Monthapply.find(params[:id])
    if @applying_month.month_request_status == "なし"
      @applying_month.update_attributes!(month_apply_params)
      flash[:success] = "#{@applying_month.month_first_day.month}月分の勤怠を申請しました。"
    elsif @applying_month.month_request_status != "なし"
      @applying_month.update_attributes!(month_apply_params)
      flash[:success] = "#{@applying_month.month_first_day.month}月分の勤怠を再度申請しました。"
    end
      redirect_to user_url(@user, date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "所属長が選択されていななかったため申請に失敗しました。"
    redirect_to user_url(@user, date: params[:date])
  end
  
  def destroy
    @applying_month.destroy
    flash[:success] = "#{@applying_month.month_first_day.month}月の申請を取り消しました。"
    redirect_to user_url(@user, date: params[:date])
  end
  
  def edit
    @month_applying = Monthapply.where(month_request_superior: @user.id, month_request_status: "申請中").order(:user_id).group_by(&:user_id)
    @first_day = params[:date]
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @applying_month = Monthapply.find_by(user_id: @user.id, month_first_day: @first_day)
    unless @applying_month.month_request_status == "なし"
      @applying_superior = User.find_by(id: @applying_month.month_request_superior)
    end
  end
  
  def applying_update
    month_applying_update_params.each do |id, item|
      monthapply = Monthapply.find(id)
      unless item[:month_request_status].blank? && item[:month_check_confirm] == "0"
        if item[:month_request_status].blank? && item[:month_check_confirm] == "1"
          flash[:danger] = "指示者確認㊞が選択されていない月があります。"
        elsif item[:month_request_status] != "申請中" && item[:month_check_confirm] == "0"
          flash[:danger] = "変更欄のチェックがされていない月があります。"
        elsif monthapply.update_attributes(item) && flash[:danger] == "更新には指示者確認㊞と変更欄のチェックが必要です。"
          flash.delete(:danger)
          flash[:success] = "勤怠の申請状態を更新しました。（１ヶ月分）"
        end
      end
      if flash[:danger].blank? && flash[:success].blank?
        flash[:danger] = "更新には指示者確認㊞と変更欄のチェックが必要です。"
      end
    end
    redirect_to user_url(date: params[:date])
  end
  
end

  private
  
  def set_applying_month
    @applying_month = Monthapply.find(params[:id])
  end

  def month_apply_params
    params.require(:user).permit(monthapplies:[:month_first_day, :month_request_status, :month_request_superior, :month_check_confirm])[:monthapplies]
  end
  
  def month_applying_update_params
    params.require(:user).permit(applying_update_months:[:month_request_status, :month_check_confirm])[:applying_update_months]
  end