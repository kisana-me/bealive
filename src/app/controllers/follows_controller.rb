class FollowsController < ApplicationController
  before_action :require_signin

  def frequest
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )

    unless @account
      return redirect_to accounts_path, alert: "指定されたアカウントは見つかりませんでした"
    end

    if @current_account == @account
      redirect_to @account, alert: "自分自身をフォローすることはできません"
      return
    end

    @follow = @current_account.active_follows.build(followed_id: @account.id)

    if @follow.save
      # フォロー成功時の処理（通知など）
      flash[:notice] = "#{@account.name}さんにフォローリクエストしました"
      redirect_to account_path(@account.name_id)
    else
      flash[:alert] = @follow.errors.full_messages.to_sentence
      redirect_to account_path(@account.name_id)
    end
  end

  def withdraw
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )

    @follow = @current_account.active_follows.find_by(followed_id: @account.id)

    unless @account && @follow
      return redirect_to accounts_path, alert: "指定されたアカウントまたはフォローは見つかりませんでした"
    end

    if @follow
      @follow.destroy
      flash[:notice] = "#{@account.name}さんのフォローを解除しました"
      redirect_to account_path(@account.name_id)
    else
      flash[:alert] = "フォローしていません"
      redirect_to account_path(@account.name_id)
    end
  end

  def accept
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
    @follow_request = Follow.find_by(followed: @current_account, follower: @account, accepted: false)

    unless @follow_request
      redirect_to root_path, alert: "対象が見つかりませんでした"
      return
    end

    if @follow_request.update(accepted: true)
      flash[:notice] = "#{@follow_request.follower.name}さんのフォローを承認しました"
    else
      flash[:alert] = @follow_request.errors.full_messages.to_sentence
    end
    redirect_to followers_account_path(@account.name_id)
  end

  def decline
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
    @follow_request = Follow.find_by(followed: @current_account, follower: @account)

    unless @follow_request
      redirect_to root_path, alert: "対象が見つかりませんでした"
      return
    end

    if @follow_request.destroy
      flash[:notice] = "#{@follow_request.follower.name}さんのフォローを拒否しました"
    else
      flash[:alert] = @follow_request.errors.full_messages.to_sentence
    end
    redirect_to followers_account_path(@account.name_id)
  end
end