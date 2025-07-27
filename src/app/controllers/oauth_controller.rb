class OauthController < ApplicationController
  # OAuth Controller for ANYUR ver 1.0.0
  # controllers/concerns/oauth_managementが必須
  # routes.rbに以下を追記
  # # OAuth
  # post "oauth" => "oauth#start"
  # get "callback" => "oauth#callback"

  include OauthManagement

  def start
    state = SecureRandom.base36(24)
    session[:oauth_state] = state
    oauth_authorize_url = generate_authorize_url(state)

    redirect_to oauth_authorize_url, allow_other_host: true
  end

  def callback
    unless params[:state] == session[:oauth_state]
      return render plain: "Invalid state parameter", status: :unauthorized
    end
    session.delete(:oauth_state)

    token_data = exchange_code_for_token(params[:code])
    return if performed?

    resources = fetch_resources(token_data["access_token"])
    return if performed?

    handle_oauth(token_data, resources)
  end

  private

  # ========== #
  # 以下自由 / handle_oauth(token_data, resources)で受け取る
  # ========== #

  def handle_oauth(token_data, resources)
    anyur_id = resources.dig("data", "id")
    account = Account.find_by(anyur_id: anyur_id, deleted: false)

    if @current_account
      if @current_account == account # 同
        account.assign_attributes(
          anyur_access_token: token_data["access_token"],
          anyur_refresh_token: token_data["refresh_token"],
          anyur_token_fetched_at: Time.current
        )
        account.meta["subscription"] = resources.dig("data", "subscription")
        account.save!
        redirect_to settings_account_path, notice: "情報を更新しました"
      elsif account # 別
        redirect_to settings_account_path, alert: "既に他のアカウントと連携済みです"
      else # 未
        @current_account.assign_attributes(
          anyur_id: resources.dig("data", "id"),
          anyur_access_token: token_data["access_token"],
          anyur_refresh_token: token_data["refresh_token"],
          anyur_token_fetched_at: Time.current
        )
        @current_account.meta["subscription"] = resources.dig("data", "subscription")
        @current_account.save!
        redirect_to settings_account_path, notice: "連携が完了しました"
      end
    else
      if account
        sign_in(account)
        account.assign_attributes(
          anyur_access_token: token_data["access_token"],
          anyur_refresh_token: token_data["refresh_token"],
          anyur_token_fetched_at: Time.current
        )
        account.meta["subscription"] = resources.dig("data", "subscription")
        account.save!
        redirect_back_or root_path, notice: "サインインしました"
      else
        session[:anyur_access_token] = token_data["access_token"]
        session[:anyur_refresh_token] = token_data["refresh_token"]
        session[:pending_oauth_id] = resources.dig("data", "id")
        #👇にまとめる
        session[:pending_oauth_info] = {
          anyur_id: resources.dig("data", "id"),
          name: resources.dig("data", "name"),
          name_id: resources.dig("data", "name_id"),
          anyur_access_token: token_data["access_token"],
          anyur_refresh_token: token_data["refresh_token"],
          subscription: resources.dig("data", "subscription")
        }
        redirect_to signup_path
      end
    end
  end
end
