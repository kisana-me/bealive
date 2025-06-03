class CapturesController < ApplicationController
  before_action :logged_in_account, except: %i[ show edit update destroy ]
  before_action :set_capture, only: %i[ show edit update ]
  before_action :set_correct_capture, only: %i[ destroy ]

  def index
    @sender_captures = Capture.where(sender: @current_account, deleted: false).limit(10).order(created_at: :desc)
    @receiver_captures = Capture.where(receiver: @current_account, deleted: false).limit(10).order(created_at: :desc)
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
    recent_count = Capture.where(sender: @current_account)
                      .where("created_at >= ?", 24.hours.ago)
                      .count

    if recent_count >= 10
      flash.now[:alert] = '作成制限：24時間以内に15件以上作成できません'
      render :new
      return
    end

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
    @capture.receiver = @current_account if @current_account
    @capture.status = 'done'
    @capture.upload = true
    if @capture.update(capture_params)
      # 通知
      unless @current_account
        session[:captured] ||= []
        session[:captured] << @capture.uuid
      end
      redirect_to capture_url(@capture.uuid), notice: "更新しました"
    else
      flash.now[:alert] = '間違っています'
      render :edit
    end
  end

  def destroy
    unless @current_account
      captured_array = session[:captured] || []
      redirect_to root_url, alert: "不可能な操作" unless captured_array.include?(@capture.uuid)
    end
    @capture.update(deleted: true)
    redirect_to root_url, notice: "削除しました"
    session[:captured].delete(@capture.uuid) if session[:captured]
  end

  private

  def set_capture
    @capture = Capture.find_by(uuid: params[:id], deleted: false)
    return render_404 unless @capture
  end

  def set_correct_capture
    @capture = Capture.find_by(uuid: params[:id], deleted: false)
    if @capture.sender == @current_account || @capture.receiver == @current_account
      return @capture
    else
      @capture = nil
    end
    return render_404 unless @capture
  end

  def capture_params
    params.require(:capture).permit(
      :front_image,
      :back_image,
      :comment,
      :latitude,
      :longitude
    )
  end
end
