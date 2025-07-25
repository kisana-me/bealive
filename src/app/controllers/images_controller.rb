class ImagesController < ApplicationController
  before_action :require_signin

  def index
    @images = Image.where(account: @current_account, deleted: false)
  end

  def show

  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    @image.account = @current_account
    
    if @image.save
      redirect_to root_path, notice: "作成しました"
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
    @image = Image.find_by(aid: params[:id], deleted: false)
    return render_404 unless @image
  end


  def image_params
    params.expect(image: [
      :name,
      :image
    ])
  end

  def update_image_params
    params.expect(image: [
      :name
    ])
  end

end
