class BasesController < ApplicationController
  before_action :set_base, only: %i[destroy update_type edit update]
  before_action :logged_in_user
  before_action :admin_user

  def index
    @bases = Base.all.order(:number)
  end

  def new
    base_number = Base.last[:number] + 1
    @base = Base.new(number: base_number)
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
    if @base.type.blank? || @base.type == '退勤'
      if @base.update(type: '出勤')
        flash[:info] = '拠点種類を出勤に更新しました。'
      else
        flash[:danger] = '拠点種類の更新に失敗しました'
      end
    elsif @base.type == '出勤'
      if @base.update(type: '退勤')
        flash[:info] = '拠点種類を退勤に更新しました。'
      else
        flash[:danger] = '拠点種類の更新に失敗しました'
      end
    end
    redirect_to bases_path
  end

  def edit; end

  def update
    @base.update!(base_params)
    flash[:success] = "#{@base.name}の情報を修正しました。"
    redirect_to bases_path
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = @base.errors.full_messages.join
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
