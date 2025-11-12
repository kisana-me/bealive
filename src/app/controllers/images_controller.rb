class ImagesController < ApplicationController
  before_action :require_signin

  def index
    @images = Image
      .is_normal
      .is_opened
      where(account: @current_account)
  end

  def show

  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    # recent_count = Image
    #   .where(account: @current_account)
    #   .where("created_at >= ?", 24.hours.ago)
    #   .count
    # max_count = 1
    # case @current_account.subscription_plan
    # when :plus then
    #   max_count = 3
    # when :premium then
    #   max_count = 4
    # when :luxury then
    #   max_count = 5
    # end
    # if recent_count >= max_count
    #   flash.now[:alert] = "作成制限: 24時間以内に#{max_count}件以上作成できません"
    #   return render :new, status: :unprocessable_entity
    # end
    @image.account = @current_account
    if @image.save
      redirect_to account_path(@current_account.name_id), notice: "作成しました"
    else
      flash.now[:alert] = "作成できませんでした"
      render :new
    end
  end

  def edit
  end

  def update
    if @image.update(update_image_params)
      redirect_to root_path, notice: "更新しました"
    else
      flash.now[:alert] = "更新できません"
      render :edit
    end
  end

  def destroy
    if @image.update(deleted: true)
      redirect_to root_url, notice: "削除しました"
    else
      flash.now[:alert] = "削除できません"
      render :edit
    end
  end

  private

  def set_image
    @image = Image
      .is_normal
      .is_opened
      .find_by(aid: params[:aid])
    return render_404 unless @image
  end


  def image_params
    params.expect(
      image: [
        :name,
        :image
      ]
    )
  end

  def update_image_params
    params.expect(
      image: [
        :name
      ]
    )
  end
end
