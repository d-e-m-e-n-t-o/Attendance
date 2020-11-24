class BasesController < ApplicationController
  before_action :set_base, only: [:destroy, :update_type, :edit, :update]
  before_action :logged_in_user, only: [:index, :new, :create, :destroy]
  before_action :admin_user, only: [:index, :new, :create, :destroy]
  
  def index
    @bases = Base.all.order(:number)
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
      if Base.exists?(number: @base[:number])
        flash[:danger] = "拠点番号#{@base.number}は既に存在しています。"
      elsif Base.exists?(name: @base[:name])
        flash[:danger] = "拠点名#{@base.name}は既に存在しています。"
      end
        @base.save!
        flash[:success] = '拠点作成に成功しました。'
        redirect_to bases_path
  rescue ActiveRecord::RecordInvalid
    redirect_to bases_path
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
    @base.update_attributes!(base_params)
    flash[:success] = "#{@base.name}の情報を修正しました。"
    redirect_to bases_path
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "修正される項目のデータが既に存在しています。"
    redirect_to bases_path
  end
  
  private
  
    def base_params
      params.require(:base).permit(:number, :name, :type)
    end
  
  # ↓ before_action_filter ↓
    def set_base
      @base = Base.find(params[:id])
    end
    
end
