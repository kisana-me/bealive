class AccountsController < ApplicationController
  before_action :set_account, except: %i[ index ]

  def index
    @accounts = Account.where(status: 0, deleted: false)
    return @accounts = [] if params[:query].blank?
    
    if params[:type] == "id"
      @accounts = @accounts.where("name_id LIKE ?", "%#{params[:query]}%")
    elsif params[:type] == "name"
      @accounts = @accounts.where("name LIKE ?", "%#{params[:query]}%")
    else
      @accounts = []
    end
  end

  def show
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
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
  end
end
