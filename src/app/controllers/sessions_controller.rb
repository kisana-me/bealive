class SessionsController < ApplicationController
  require "net/http"
  before_action :logged_in_account, except: %i[ start oauth callback ]
  before_action :logged_out_account, only: %i[ start oauth callback ]
  before_action :set_session, only: %i[ show edit update destroy ]

  def start
    #「続ける」
  end

  def oauth
    state = SecureRandom.base36(24)
    session[:oauth_state] = state
    oauth_authorize_url = "https://anyur.com/oauth/authorize?" + {
      response_type: "code",
      client_id: "Be_Alive",
      redirect_uri: "https://bealive.amiverse.net/sessions/callback",
      scope: "id name name_id",
      state: state
    }.to_query

    redirect_to oauth_authorize_url, allow_other_host: true
  end

  def callback
    if params[:state] != session[:oauth_state]
      render plain: "Invalid state parameter", status: :unauthorized
      return
    end
    session.delete(:oauth_state)
    code = params[:code]
    token_response = Net::HTTP.post_form(
      URI("https://anyur.com/oauth/token"),
      {
        grant_type: "authorization_code",
        client_id: "Be_Alive",
        client_secret: ENV["OAUTH_CLIENT_SECRET"],
        redirect_uri: "https://bealive.amiverse.net/sessions/callback",
        code: code
      }
    )
    if token_response.code.to_i != 200
      render plain: "OAuth token request failed: #{token_response.code} #{token_response.body}", status: :unauthorized
      return
    end
    token_data = JSON.parse(token_response.body)
    access_token = token_data["access_token"]
    expires_in = token_data["expires_in"]
    refresh_token = token_data["refresh_token"]
    # データ取得
    info_uri = URI("https://anyur.com/api/resources")
    info_request = Net::HTTP::Post.new(info_uri)
    info_request["Authorization"] = "Bearer #{access_token}"
    info_request["Content-Type"] = "application/json"
    info_response = Net::HTTP.start(info_uri.hostname, info_uri.port, use_ssl: info_uri.scheme == "https") do |http|
      http.request(info_request)
    end
    if info_response.code.to_i != 200
      render plain: "Information request failed: #{info_response.code} #{info_response.body}", status: :unauthorized
      return
    end
    info = JSON.parse(info_response.body)
    # サインイン or サインアップ
    account = Account.find_by(anyur_id: info.dig("data", "id"), deleted: false)
    if account
      # account.metaに4つ記録
      log_in(account)
      redirect_to root_path, notice: "サインインしました"
    else
      session[:pending_oauth_id] = info.dig("data", "id")
      session[:pending_oauth_info] = {name: info.dig("data", "name"), name_id: info.dig("data", "name_id")}
      redirect_to signup_path
    end
  end

  # 以下サインイン済み #

  def index
    @sessions = Session.where(account: @current_account, deleted: false)
  end

  def show
  end

  def edit
  end

  def update
    if @session.update!(session_params)
      redirect_to session_path(@session.lookup), notice: "セッションを更新しました"
    else
      render :edit
    end
  end

  def destroy
    @session.update(deleted: true)
    redirect_to sessions_path, notice: "セッションを削除しました"
  end

  def logout
    if log_out
      redirect_to root_path, notice: 'ログアウトしました'
    else
      redirect_to root_path, alert: 'ログアウトできませんでした'
    end
  end

  private

  def set_session
    @session = Session.find_by(account: @current_account, lookup: params[:id], deleted: false)
  end

  def session_params
    params.require(:session).permit(:name)
  end
end
