module SessionManagement
  def current_account
    @current_account = nil
    return if cookies.signed[:bealive].blank?
    account = Account.find_by_session(cookies.signed[:bealive])
    return unless account
    @current_account = account
  end

  def sign_in(account)
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

  def sign_out
    return if cookies.signed[:bealive].blank?
    db_session = Session.find_by_token("token", cookies.signed[:bealive])
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