class CapturesController < ApplicationController
  before_action :require_signin, only: %i[ index sended received new create ]
  before_action :set_visible_capture, only: %i[ show capture post_capture ]
  before_action :set_owned_capture, only: %i[ edit update destroy ]

  def index
    following_ids = @current_account.accepted_following.pluck(:id)
    @captures = Capture
      .captured
      .where(receiver_id: following_ids)
      .where(visibility: [:followers_only, :public])
      .limit(10)
  end

  def sended
    @undone_captures = Capture
      .where(captured_at: nil)
      .where(sender: @current_account)
    
    @captures = Capture
      .captured
      .where(sender: @current_account)
      .where("captures.receiver_id IS NULL OR captures.receiver_id = ?", @current_account.id)
      .limit(10)
  end

  def received
    @captures = Capture
      .captured
      .where(receiver: @current_account)
      .limit(10)
  end

  def load_more
    capture = Capture.find_by(aid: params[:offset])
    unless capture
      return render turbo_stream: turbo_stream.update("load-more", partial: "captures/load_end")
    end
    @captures = Capture
      .captured
      .where("captures.captured_at < ?", capture.captured_at)
      .limit(10)
    if @current_account && params[:type] == "following"
      following_ids = @current_account.accepted_following.pluck(:id)
      @captures = @captures
        .where(visibility: [:followers_only, :public])
        .where(receiver_id: following_ids)
    elsif @current_account && params[:type] == "sended"
      @captures = @captures
        .where(sender: @current_account)
        .where("captures.receiver_id IS NULL OR captures.receiver_id = ?", @current_account.id)
    elsif @current_account && params[:type] == "received"
      @captures = @captures.where(receiver: @current_account)
    elsif params[:type] == "account"
      @captures = @captures.where(receiver: capture.receiver, visibility: [:public])
    else
      @captures = @captures.where(visibility: [:public])
    end
    unless @captures.present?
      return render turbo_stream: turbo_stream.update("load-more", partial: "captures/load_end")
    end
    ts = []
      if params[:layout] == "rc"
        ts << turbo_stream.append("captures", partial: "captures/captures", locals: { captures: @captures })
      else
        ts << turbo_stream.append("captures", partial: "captures/capture", collection: @captures, locals: { show_comment: true })
      end
      if @captures.count == 10
        ts << turbo_stream.update("load-more", partial: "captures/load_more", locals: { offset: @captures.last.aid, type: params[:type], layout: params[:layout] })
      else
        ts << turbo_stream.update("load-more", partial: "captures/load_end")
      end
    render layout: false, turbo_stream: ts
  end

  def show
  end

  def new
    @capture = Capture.new
  end

  def create
    @capture = Capture.new(sender_comment: params[:capture][:sender_comment])
    recent_count = Capture
      .where(sender: @current_account)
      .where("captures.created_at >= ?", 24.hours.ago)
      .count
    max_count = 5
    case @current_account.subscription_plan
    when :plus then
      max_count = 10
    when :premium then
      max_count = 15
    when :luxury then
      max_count = 20
    end
    if recent_count >= max_count
      flash.now[:alert] = "作成制限: 24時間以内に#{max_count}件以上作成できません"
      return render :new, status: :unprocessable_entity
    end
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
    return redirect_to capture_path(params[:aid]) unless @capture
    if !@capture.captured_at.nil?
      redirect_to capture_path(@capture.aid), alert: "撮影済み"
    end
    @capture.build_front_photo
    @capture.build_back_photo
  end

  def post_capture
    return redirect_to capture_path(params[:aid]) unless @capture
    if !@capture.captured_at.nil?
      redirect_to capture_path(@capture.aid), alert: "撮影済み"
    end
    @capture.assign_attributes(receiver_params)
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

  def set_visible_capture
    @capture = Capture.find_by(aid: params[:aid])
    return unless @capture
    return if @capture.owner == @current_account

    return if @capture.visibility_public?
    return if @capture.visibility_link_only?
    
    case @capture.visibility
    when "followers_only" then
      return @capture = nil unless @capture.owner.accepted_passive_follows.include?(@current_account)
    when "group_only" then
      return @capture = nil
    end
    @capture = nil
  end

  def set_owned_capture
    @capture = Capture.find_by(aid: params[:aid])
    return redirect_to capture_path(params[:aid]) unless @capture
    return if @capture.owner == @current_account
    return if session[:captured]&.include?(@capture.aid) && !@capture.receiver
    redirect_to capture_path(@capture.aid), alert: "権限がありません"
  end

  def receiver_params
    params.require(:capture).permit(
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
      :visibility
    ])
  end

end
