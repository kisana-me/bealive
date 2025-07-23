class SettingsController < ApplicationController

  def index
  end

  def account
  end

  def icon
    @images = Image.where(account: @current_account, deleted: false)
  end

  def post_account
    if @current_account.update(account_params)
      redirect_to settings_account_path, notice: "更新しました"
    else
      render :account
    end
  end

  def leave
    @current_account.update(deleted: true)
    sign_out
    redirect_to root_url, notice: "ご利用いただきありがとうございました"
  end

  private

  def account_params
    params.require(:account).permit(
      :name,
      :name_id,
      :description,
      :birth,
      :icon_aid
    )
  end

end
