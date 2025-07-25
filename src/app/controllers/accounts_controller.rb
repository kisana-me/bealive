class AccountsController < ApplicationController

  def index
  end

  def show
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
  end

  def following
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
    unless @account
      return redirect_to account_path(params[:name_id])
    end
    @accepted_following = @account.accepted_following.order(created_at: :desc)
    @pending_following_requests = @account.active_follows.where(accepted: false).order(created_at: :desc)
  end

  def followers
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
    unless @account
      return redirect_to account_path(params[:name_id])
    end
    @accepted_followers = @account.accepted_followers.order(created_at: :desc)
    @pending_follow_requests = @account.passive_follows.where(accepted: false).order(created_at: :desc)
  end

end
