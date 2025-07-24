class SignupController < ApplicationController
  before_action :require_signout
  before_action :ensure_oauth_context

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    @account.anyur_id = session[:pending_oauth_id]

    if @account.save
      session.delete(:pending_oauth_id)
      session.delete(:pending_oauth_info)
      sign_in(@account)
      @account.update(
        anyur_access_token: session[:anyur_access_token],
        anyur_refresh_token: session[:anyur_refresh_token]
      )
      session.delete(:anyur_access_token)
      session.delete(:anyur_refresh_token)
      redirect_to root_path, notice: "登録完了"
    else
      render :new
    end
  end

  private

  def ensure_oauth_context
    unless session[:pending_oauth_id].present?
      render plain: "不正なアクセス", status: :forbidden
    end
  end

  def account_params
    params.require(:account).permit(
      :name,
      :name_id,
      :description
    )
  end
end
