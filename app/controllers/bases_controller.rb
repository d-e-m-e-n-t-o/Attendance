class BasesController < ApplicationController
  before_action :set_base, only: [:destroy, :update_type, :edit, :update]
  before_action :logged_in_user, only: [:index, :new, :create, :destroy]
  before_action :admin_user, only: [:index, :new, :create, :destroy]
  
  def index
    @bases = Base.all
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点作成に成功しました。'
      redirect_to bases_path
    else
      flash.now[:danger] = "拠点作成に失敗しました。"
      render :new
    end
  end
  
  def destroy
    @base.destroy
    flash[:success] = "#{@base.name}のデータを削除しました。"
    redirect_to bases_path
  end
  
  def update_type
    if @base.type.blank? || @base.type == "退勤"
      if @base.update_attributes(type: "出勤")
        flash[:info] = "拠点種類を出勤に更新しました。"
      else
        flash[:danger] = "拠点種類の更新に失敗しました"
      end
    elsif @base.type == "出勤"
      if @base.update_attributes(type: "退勤")
        flash[:info] = "拠点種類を退勤に更新しました。"
      else
        flash[:danger] = "拠点種類の更新に失敗しました"
      end
    end
    redirect_to bases_path
  end
  
  def edit
  end
  
  def update
    if @base.update_attributes(base_params)
      flash[:success] = "#{@base.name}の情報を修正しました。"
    else
      flash[:danger] = "#{@base.name}の情報修正に失敗しました。"
    end
      redirect_to bases_path
  end
  
  private
  
    def base_params
      params.require(:base).permit(:name, :type)
    end
  
  # ↓ before_action_filter ↓
    def set_base
      @base = Base.find(params[:id])
    end
    
end
