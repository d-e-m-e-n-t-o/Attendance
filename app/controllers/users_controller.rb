class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :update_overtime_application]
  before_action :logged_in_user, only: [:show, :edit, :update, :index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  
  def new
    @user = User.new
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @applying = Attendance.find_by(worked_on: @first_day)
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
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end
  
  def index
    @users = params[:search].present? ?
    User.where('name LIKE ?', "%#{params[:search]}%").paginate(page: params[:page]) :
    User.paginate(page: params[:page])
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def import
    User.import(params[:file].path)
    redirect_to users_url
  end
  
  def get_commuting_list
    @user_ids = Attendance.where(worked_on: Date.today).where.not(started_at: nil).where(finished_at: nil).pluck(:user_id)
    @users = User.where(id: @user_ids)
    if @users.blank?
      flash.now[:danger] = "現在出勤中の社員はおりません。"
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password,
      :basic_time, :designated_work_start_time, :designated_work_end_time)
    end
end

