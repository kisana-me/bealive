class SessionsController < ApplicationController
  before_action :logged_in_account, except: %i[ new create ]
  before_action :set_session, only: %i[ show edit update destroy ]

  def index
    @sessions = Session.where(account: @current_account, deleted: false)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    account = Account.find_by(name_id: params[:name_id], deleted: false)
    if account && account.authenticate(params[:password])
      log_in(account)
      redirect_to root_path, notice: 'ログインしました'
    else
      @name_id = params[:name_id]
      flash.now[:alert] = '間違っています'
      render :new
    end
  end

  def logout
    if log_out
      redirect_to root_path, notice: 'ログアウトしました'
    else
      redirect_to root_path, alert: 'ログアウトできませんでした'
    end
  end

  def update
    if @session.update!(session_params)
      redirect_to session_url(@session.uuid), notice: "セッションを更新しました"
    else
      render :edit
    end
  end

  def destroy
    @session.update(deleted: true)
    redirect_to root_path, notice: "セッションを削除しました"
  end

  private

  def set_session
    @session = Session.find_by(account: @current_account, uuid: params[:id], deleted: false)
  end

  def session_params
    params.require(:session).permit(:name)
  end
end
