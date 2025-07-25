class CapturesController < ApplicationController
  before_action :require_signin, only: %i[ index new create ]
  before_action :set_capture, except: %i[ index new create ]

  def index
    followed_account_ids = @current_account.accepted_following.pluck(:id)
    @captures = Capture
      .where(receiver_id: followed_account_ids)
      .where(visibility: [:following_only, :public])
      .order(captured_at: :desc)
      .limit(30)
      .includes(:front_photo, :back_photo, sender: :icon, receiver: :icon)

    @sender_captures = Capture
      .where(sender: @current_account, deleted: false)
      .order(captured_at: :desc)
      .limit(30)
      .includes(:front_photo, :back_photo, sender: :icon, receiver: :icon)
    @receiver_captures = Capture
      .where(receiver: @current_account, deleted: false)
      .order(captured_at: :desc)
      .limit(30)
      .includes(:front_photo, :back_photo, sender: :icon, receiver: :icon)
  end

  def show
    @destroy_flag = false
    if @current_account
      @destroy_flag ||= @capture.sender == @current_account if @capture.sender
      @destroy_flag ||= @capture.receiver == @current_account if @capture.receiver
    end
    @destroy_flag ||= session[:captured]&.include?(@capture.aid)
  end

  def new
    @capture = Capture.new
  end

  def create
    recent_count = Capture.where(sender: @current_account)
                      .where("created_at >= ?", 24.hours.ago)
                      .count

    if recent_count >= 10
      flash.now[:alert] = "作成制限：24時間以内に10件以上作成できません"
      @capture = Capture.new
      return render :new, status: :unprocessable_entity
    end

    @capture = Capture.new(sender_comment: params[:capture][:sender_comment])
    @capture.sender = @current_account
    if @capture.save
      redirect_to capture_url(@capture.aid), notice: "作成しました"
    else
      flash.now[:alert] = "間違っています"
      render :new
    end
  end

  def edit
  end

  def update
    if @capture.update(update_capture_params)
      redirect_to capture_url(@capture.aid), notice: "更新しました"
    else
      flash.now[:alert] = "更新できません"
      render :capture
    end
  end

  def capture
    if !@capture.captured_at.nil?
      redirect_to capture_path(@capture.aid), alert: "撮影済み"
    end
    @capture.build_front_photo
    @capture.build_back_photo
  end

  def post_capture
    if !@capture.captured_at.nil?
      redirect_to capture_path(@capture.aid), alert: "撮影済み"
    end
    @capture.assign_attributes(capture_params)
    @capture.captured_at = Time.current
    @capture.receiver = @current_account if @current_account
    @capture.upload_photo = true
    if @capture.save
      # 通知
      unless @current_account
        session[:captured] ||= []
        session[:captured] << @capture.aid
      end
      redirect_to capture_url(@capture.aid), notice: "更新しました"
    else
      flash.now[:alert] = "間違っています"
      render :capture
    end
  end

  def destroy
    unless @current_account
      captured_array = session[:captured] || []
      return redirect_to root_url, alert: "不可能な操作" unless captured_array.include?(@capture.aid)
    end
    @capture.update(deleted: true)
    redirect_to root_url, notice: "削除しました"
    session[:captured].delete(@capture.aid) if session[:captured]
  end

  private

  def set_capture
    @capture = Capture.find_by(aid: params[:id], deleted: false)
    return render_404 unless @capture
  end

  def capture_params
    params.require(:capture).permit(
      :sender_comment,
      :receiver_comment,
      :latitude,
      :longitude,
      :visibility,
      front_photo_attributes: [:image],
      back_photo_attributes: [:image]
    )
  end

  def update_capture_params
    params.expect(capture: [
      :visibility,
      :latitude,
      :longitude
    ])
  end

end
