class SessionsController < ApplicationController
  before_action :logged_in_account, except: %i[ new create ]
  before_action :set_session, only: %i[ show edit update destroy ]

  def index
    @sessions = Session.where(account: @current_account, deleted: false)
  end

  def show
  end

  def new
    @reform
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

  # PATCH/PUT /sessions/1 or /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to session_url(@session), notice: "Session was successfully updated." }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1 or /sessions/1.json
  def destroy
    @session.destroy!

    respond_to do |format|
      format.html { redirect_to sessions_url, notice: "Session was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_session
    @session = Session.find_by(uuid: params[:id], deleted: false)
  end

  def session_params
    params.require(:session).permit()
  end
end
