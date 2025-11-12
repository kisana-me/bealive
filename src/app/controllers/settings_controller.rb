class SettingsController < ApplicationController
  before_action :require_signin
  before_action :set_account, only: %i[ account icon post_account ]

  def index
  end

  def account
  end

  def icon
    @images = Image
      .is_normal
      .is_opened
      .where(account: @current_account)
  end

  def post_account
    if @account.update(account_params)
      redirect_to settings_account_path, notice: "更新しました"
    else
      render :account
    end
  end

  def leave
    @current_account.update(status: :deleted)
    sign_out
    redirect_to root_url, notice: "ご利用いただきありがとうございました"
  end

  private

  def set_account
    @account = Account.find_by(aid: @current_account.aid)
  end

  def account_params
    params.require(:account).permit(
      :name,
      :name_id,
      :description,
      :birthdate,
      :icon_aid
    )
  end
end
