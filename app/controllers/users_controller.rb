class UsersController < ApplicationController
  before_action :set_user_id,
                only: %i[show edit update destroy edit_basic_info update_basic_info update_overtime_application]
  before_action :logged_in_user,
                only: %i[show edit update index destroy edit_basic_info update_basic_info import get_commuting_list]
  before_action :correct_user, only: %i[show edit update]
  before_action :superior_or_correct_user, only: [:show]
  before_action :admin_user,
                only: %i[index destroy edit_basic_info update_basic_info import get_commuting_list]
  before_action :set_one_month, only: :show

  def new
    employee_number_temp = User.last.nil? ? '1' : (User.last[:employee_number].to_i + 1).to_s
    uid_temp = SecureRandom.urlsafe_base64
    uid_temp = SecureRandom.urlsafe_base64 while User.exists?(uid: uid_temp)
    @user = User.new(employee_number: employee_number_temp, uid: uid_temp)
  end

  def show
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @applying_month = Monthapply.find_by(user_id: @user.id, month_first_day: @first_day)
    if @applying_month.month_request_status != 'なし' || @applying_month.month_check_confirm == true
      @applying_month_superior = User.find_by(id: @applying_month.month_request_superior)
    end
    @applying_month_count = Monthapply.where(month_request_superior: @user.id, month_request_status: '申請中').count
    @applying_edit_day_count = Attendance.where(edit_day_request_superior: @user.id,
                                                edit_day_request_status: '申請中').count
    @applying_over_count = Attendance.where(over_request_superior: @user.id, over_request_status: '申請中').count
    @monthapplies_update_applying = @user.monthapplies.where(month_check_confirm: true)
    @edit_day_update_applying = @user.attendances.where(edit_day_check_confirm: true)
    @over_update_applying = @user.attendances.where(over_check_confirm: true)
    @update_applying_count = @monthapplies_update_applying.count.to_i + @edit_day_update_applying.count.to_i + @over_update_applying.count.to_i
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'ユーザー情報を更新しました。'
      redirect_to @user
    else
      render :edit
    end
  end

  def index
    @users = if params[:search].present?
               User.where('name LIKE ?', "%#{params[:search]}%").paginate(page: params[:page], per_page: 10)
             else
               User.paginate(page: params[:page], per_page: 10)
             end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info; end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join('<br>')
    end
    redirect_to users_url
  end

  def import
    User.import(params[:file].path)
    redirect_to users_url
  end

  def get_commuting_list
    @user_ids = Attendance.where.not(started_at: nil).where(finished_at: nil).pluck(:user_id)
    @users = User.where(id: @user_ids)
    flash.now[:danger] = '現在出勤中の社員はおりません。' if @users.blank?
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password,
                                   :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:name, :superior, :admin, :email, :affiliation, :employee_number, :uid, :password,
                                   :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
end
