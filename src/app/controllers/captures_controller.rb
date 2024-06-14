class CapturesController < ApplicationController
  before_action :logged_in_account, except: %i[ show edit update ]
  before_action :set_capture, only: %i[ show edit update destroy ]

  def index
    @captures = Capture.where(sender: @current_account, deleted: false)
  end

  def show
  end

  def new
    @capture = Capture.new
  end

  def edit
    # いらない？
    if @capture.done?
      redirect_to capture_path(@capture.uuid), alert: '撮影済み'
    end
  end

  def create
    @capture = Capture.new
    @capture.uuid = SecureRandom.uuid
    @capture.sender = @current_account
    @capture.status = 'waiting'
    if @capture.save
      redirect_to capture_url(@capture.uuid), notice: "作成しました"
    else
      flash.now[:alert] = '間違っています'
      render :new
    end
  end

  def update
    if @capture.done?
      redirect_to capture_path(@capture.uuid), alert: '撮影済み'
    end
    @capture.captured_at = Time.now
    @capture.status = 'done'
    @capture.upload = true
    if @capture.update(capture_params)
      # 画像
      # ステータス更新
      redirect_to capture_url(@capture.uuid), notice: "更新しました"
    else
      flash.now[:alert] = '間違っています'
      render :edit
    end
  end

  def destroy
    @capture.udpate(delete: true)
    redirect_to captures_url, notice: "削除しました"
  end

  private

  def set_capture
    @capture = Capture.find_by(uuid: params[:id], deleted: false)
  end

  def capture_params
    params.require(:capture).permit(
      :front_image,
      :back_image,
      :name,
      :latitude,
      :longitude
    )
  end
end
