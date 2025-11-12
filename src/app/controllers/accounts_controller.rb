class AccountsController < ApplicationController
  before_action :set_account, except: %i[ index ]

  def index
    return @accounts = [] if params[:query].blank?
    
    @accounts = Account.is_normal.is_opened.order(id: :desc)
    if params[:type] == "id"
      @accounts = @accounts.where("name_id LIKE ?", "%#{params[:query]}%")
    elsif params[:type] == "name"
      @accounts = @accounts.where("name LIKE ?", "%#{params[:query]}%")
    else
      @accounts = []
    end
  end

  def show
    @captures = Capture
      .is_normal
      .is_opened
      .is_captured
      .where(receiver: @account)
      .limit(10)
  end

  def following
    return redirect_to account_path(params[:name_id]) unless @account
    @accepted_following = @account.accepted_following.order(created_at: :desc)
    @pending_following_requests = @account.active_follows.where(accepted: false).order(created_at: :desc)
  end

  def followers
    return redirect_to account_path(params[:name_id]) unless @account
    @accepted_followers = @account.accepted_followers.order(created_at: :desc)
    @pending_follow_requests = @account.passive_follows.where(accepted: false).order(created_at: :desc)
  end

  private

  def set_account
    @account = Account
      .is_normal
      .is_opened  
      .find_by(name_id: params[:name_id])
    return if @account

    return render_404 unless @current_account

    if @current_account.name_id == params[:name_id]
      @account = @current_account
      return
    end
    
    if admin?
      @account = Account.find_by(name_id: params[:name_id])
      return if @account
    end

    render_404
  end
end
