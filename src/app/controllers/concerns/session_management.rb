module SessionManagement
  def current_account
    return nil unless cookies.signed[:ba_uid].present? && cookies.signed[:ba_rtk].present?
    db_session = Session.find_by(uuid: cookies.signed[:ba_uid], deleted: false)
    if db_session && BCrypt::Password.new(db_session.digest).is_password?(cookies.signed[:ba_rtk])
      account = db_session.account
      unless account.deleted == true
        return account
      end
    end
    return nil
  end

  def log_in(account)
    uuid = SecureRandom.uuid
    token = SecureRandom.urlsafe_base64
    db_session = Session.create(
      account: account,
      uuid: uuid,
      digest: digest(token),
      name: request.user_agent,
      ip: request.remote_ip
    )
    secure_cookies = ENV["RAILS_SECURE_COOKIES"].present?
    cookies.permanent.signed[:ba_uid] = {
      value: uuid,
      domain: :all,
      expires: 1.month.from_now,
      secure: secure_cookies,
      httponly: true
    }
    cookies.permanent.signed[:ba_rtk] = {
      value: token,
      domain: :all,
      expires: 1.month.from_now,
      secure: secure_cookies,
      httponly: true
    }
  end

  def log_out
    return nil unless cookies.signed[:ba_uid].present? && cookies.signed[:ba_rtk].present?
    db_session = Session.find_by(uuid: cookies.signed[:ba_uid], deleted: false)
    if BCrypt::Password.new(db_session.digest).is_password?(cookies.signed[:ba_rtk])
      account = db_session.account
      if account && !account.deleted
        db_session.update(deleted: true)
      end
    end
    cookies.delete(:ba_uid)
    cookies.delete(:ba_rtk)
  end

  private

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
      BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end