class AccountsController < ApplicationController

  def index
    @accounts = Account.where(
      status: 0,
      deleted: false
    )
    .order(id: :desc)
    .limit(10)
  end

  def show
    @account = Account.find_by(
      name_id: params[:name_id],
      status: 0,
      deleted: false
    )
  end

end
