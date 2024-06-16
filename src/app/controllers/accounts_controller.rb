class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show ]
  before_action :set_correct_account, only: %i[ edit update destroy ]

  def index
  end

  def show
  end

  def new
    @account = Account.new
  end

  def edit
  end

  def create
    @account = Account.new(account_params)
    invitation = Invitation.find_by(code: params[:invitation_code])
    if params[:invitation_code] == 'first'
      if Account.last
        flash.now[:alert] = '招待コードが正しくありません!'
        render :new
        return
      end
    else
      unless invitation && invitation.uses < invitation.max_uses
        flash.now[:alert] = '招待コードが正しくありません'
        render :new
        return
      end
    end
    @account.uuid = SecureRandom.uuid
    @account.invitation_id = invitation.id if invitation
    if @account.save
      invitation.update!(uses: invitation.uses + 1) if invitation
      redirect_to login_path, notice: "アカウントを作成しました"
    else
      render :new
    end
  end

  def update
    if @account.update(update_account_params)
      redirect_to account_path(@account.name_id), notice: "更新しました"
    else
      render :edit
    end
  end

  def destroy
    @account.update(deleted: true)
    redirect_to root_url, notice: "ご利用いただきありがとうございました"
  end

  def search_account
    @account = Account.find_by(name_id: params[:query], deleted: false)
    return render_404 unless @account
    redirect_to account_path(@account.name_id)
  end

  private

  def set_account
    @account = Account.find_by(name_id: params[:id], deleted: false)
    render_404 unless @account
  end
  def set_correct_account
    @account = Account.find_by(name_id: params[:id], deleted: false)
    if @current_account == @account
      return @account
    else
      return render_404
    end
  end

  def account_params
    params.require(:account).permit(
      :name,
      :name_id,
      :description,
      :birth,
      :email,
      :phone,
      :password,
      :password_confirmation
    )
  end
  def update_account_params
    params.require(:account).permit(
      :name,
      :name_id,
      :description,
      :birth,
      :email,
      :phone
    )
  end
  def password_update_account_params
    params.require(:account).permit(
      :password,
      :password_confirmation
    )
  end
end
