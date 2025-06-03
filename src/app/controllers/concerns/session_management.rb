module SessionManagement
  def current_account
    @current_account = nil
    return if cookies.signed[:bealive].blank?
    account = Account.find_by_session(cookies.signed[:bealive])
    return unless account
    @current_account = account
  end

  def log_in(account)
    token = account.remember(request.remote_ip, request.user_agent)
    cookies.signed[:bealive] = {
      value: token,
      domain: :all,
      tld_length: 3,
      same_site: :lax,
      expires: 1.month.from_now,
      secure: Rails.env.production?,
      httponly: true
    }
  end

  def log_out
    # return nil unless cookies.signed[:ba_uid].present? && cookies.signed[:ba_rtk].present?
    # db_session = Session.find_by(uuid: cookies.signed[:ba_uid], deleted: false)
    # if BCrypt::Password.new(db_session.digest).is_password?(cookies.signed[:ba_rtk])
    #   account = db_session.account
    #   if account && !account.deleted
    #     db_session.update(deleted: true)
    #   end
    # end

    
    return if cookies.signed[:bealive].blank?
    db_session = Session.find_by_token(cookies.signed[:bealive])
    return unless db_session
    cookies.delete(:bealive)
    db_session.update(deleted: true)
  end

  private

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
      BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end