class FollowsController < ApplicationController
  before_action :require_signin
  before_action :set_account

  def frequest
    return redirect_to account_path(@account.name_id), alert: "自分自身はフォローできません" if @current_account == @account
    @follow = @current_account.active_follows.build(followed_id: @account.id)

    if @follow.save
      # フォロー成功時の処理（通知など）
      flash[:notice] = "フォロー(リクエスト)しました"
      redirect_to account_path(@account.name_id)
    else
      flash[:alert] = "フォロー(リクエスト)できませんでした"
      redirect_to account_path(@account.name_id)
    end
  end

  def withdraw
    @follow = @current_account.active_follows.find_by(followed_id: @account.id)
    return redirect_to account_path(@account.name_id), alert: "対象のフォローが見つかりません" unless @follow

    if @follow.destroy
      flash[:notice] = "フォロー(リクエスト)を解除しました"
    else
      flash[:alert] = "フォロー(リクエスト)を解除できませんでした"
    end
    redirect_to account_path(@account.name_id)
  end

  def accept
    @follow_request = Follow.find_by(followed: @current_account, follower: @account, accepted: false)
    return redirect_to account_path(@account.name_id), alert: "対象のフォローリクエストが見つかりません" unless @follow_request

    if @follow_request.update(accepted: true)
      flash[:notice] = "フォローリクエストを承認しました"
    else
      flash[:alert] = "フォローリクエストを承認できませんでした"
    end
    redirect_to followers_account_path(@current_account.name_id)
  end

  def decline
    @follow = Follow.find_by(followed: @current_account, follower: @account)
    return redirect_to account_path(@account.name_id), alert: "対象のフォロー(リクエスト)が見つかりません" unless @follow

    if @follow.destroy
      flash[:notice] = "フォロー(リクエスト)を却下しました"
    else
      flash[:alert] = "フォロー(リクエスト)を却下できませんでした"
    end
    redirect_to followers_account_path(@current_account.name_id)
  end

  private

  def set_account
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
    return redirect_to account_path(params[:name_id]), alert: "対象のアカウントが見つかりません" unless @account
  end
end