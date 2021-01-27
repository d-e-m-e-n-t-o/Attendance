class MonthappliesController < ApplicationController
  before_action :set_user_user_id, only: %i[update destroy_month_apply edit show]
  before_action :set_applying_month, only: %i[update destroy_month_apply]
  before_action :set_one_month, only: :show
  before_action :logged_in_user
  before_action :correct_user, only: %i[update destroy_month_apply]
  before_action :superior_user, only: %i[edit applying_update show]

  # ↓ 勤怠申請 ↓
  def update
    @applying_month = Monthapply.find(params[:id])
    if @applying_month.month_request_status == 'なし'
      @applying_month.update_attributes!(month_apply_params)
      flash[:success] = "#{@applying_month.month_first_day.month}月分の勤怠を申請しました。"
    elsif @applying_month.month_request_status != 'なし'
      @applying_month.update_attributes!(month_apply_params)
      flash[:success] = "#{@applying_month.month_first_day.month}月分の勤怠を再度申請しました。"
    end
    redirect_to user_url(@user, date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = '所属長が選択されていななかったため申請に失敗しました。'
    redirect_to user_url(@user, date: params[:date])
  end

  def destroy_month_apply
    if @applying_month[:month_request_status] == '申請中'
      @applying_month.update_attributes(month_request_superior: nil, month_request_status: 'なし',
                                        month_check_confirm: nil)
      flash[:success] = "#{@applying_month.month_first_day.month}月の申請を取り消しました。"
    else
      flash[:danger] = '上長より申請が取り消されました。' if @applying_month.month_request_status == 'なし'
      flash[:danger] = "上長より#{@applying_month.month_request_status}されたため、申請取消に失敗しました。"
    end
    redirect_to user_url(@user, date: params[:date])
  end

  # ↓勤怠承認 ↓
  def edit
    @month_applying = Monthapply.where(month_request_superior: @user.id,
                                       month_request_status: '申請中').order(:user_id).group_by(&:user_id)
    @first_day = params[:date]
  end

  def applying_update
    month_applying_update_params.each do |id, item|
      month = Monthapply.find(id)
      if item[:month_request_status].present? && item[:month_request_status] != '申請中' && item[:month_check_confirm] == '1'
        if item[:month_request_status] == 'なし'
          month.update_attributes(month_request_status: 'なし',
                                  month_check_confirm: '1')
        end
        month.update_attributes(item)
        flash.delete(:info)
        flash[:success] = '勤怠の申請状態を変更しました。'
      elsif item[:month_request_status].blank? && item[:month_check_confirm] == '0'
        if flash[:danger].blank? && flash[:warning].blank? && flash[:success].blank?
          flash[:info] =
            '申請状態を変更するには、指示書確認㊞と変更欄のチェックが必要です。'
        end
      else
        if item[:month_request_status].blank? && item[:month_check_confirm] == '1'
          flash[:danger] =
            '指示者確認㊞が選択されていない申請があります。'
        end
        if item[:month_request_status] != '申請中' && item[:month_check_confirm] == '0'
          flash[:warning] =
            '変更欄のチェックがされていない申請があります。'
        end
        flash.delete(:info) if flash[:danger].present? || flash[:warning].present?
        flash.delete(:success) if flash[:danger].present? || flash[:warning].present?
      end
    end
    redirect_to user_url(date: params[:date])
  end

  def show
    @login_user = User.find(params[:login_user])
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @applying_month = Monthapply.find_by(user_id: @user.id, month_first_day: @first_day)
    if @applying_month.month_request_status != 'なし' || @applying_month.month_check_confirm == true
      @applying_month_superior = User.find_by(id: @applying_month.month_request_superior)
    end
  end

  private

    def set_applying_month
      @applying_month = Monthapply.find(params[:id])
    end

    def month_apply_params
      params.require(:user).permit(monthapplies: %i[month_first_day month_request_status month_request_superior
                                                    month_check_confirm])[:monthapplies]
    end

    def month_applying_update_params
      params.require(:user).permit(applying_update_months: %i[month_request_status
                                                              month_check_confirm])[:applying_update_months]
    end
end
