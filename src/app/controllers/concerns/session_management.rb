module SessionManagement # 単一サインイン版 ver.1
  # models/token_toolsが必須
  # Sessionに必要なカラム差分(名前 型)
  # account references
  # ip_address string
  # user_agent string
  # Accountに必要なカラム
  # deleted boolean
  COOKIE_NAME = "bealive"
  COOKIE_EXPIRES = 1.month # 2592000

  def current_account
    @current_account = nil
    return if cookies.encrypted[COOKIE_NAME.to_sym].blank?
    db_session = Session.find_by_token("token", cookies.encrypted[COOKIE_NAME.to_sym])
    if db_session&.account && !db_session.account.deleted
      @current_account = db_session.account
    else
      cookies.delete(COOKIE_NAME.to_sym)
    end
  end

  def sign_in(account)
    db_session = Session.new(account: account, ip_address: request.remote_ip, user_agent: request.user_agent)
    token = db_session.generate_token("token", COOKIE_EXPIRES)
    cookies.encrypted[COOKIE_NAME.to_sym] = {
      value: token,
      domain: :all,
      tld_length: 3,
      same_site: :lax,
      expires: Time.current + COOKIE_EXPIRES,
      secure: Rails.env.production?,
      httponly: true
    }
    db_session.save
  end

  def sign_out
    return if cookies.encrypted[COOKIE_NAME.to_sym].blank?
    db_session = Session.find_by_token("token", cookies.encrypted[COOKIE_NAME.to_sym])
    return unless db_session
    cookies.delete(COOKIE_NAME.to_sym)
    db_session.update(deleted: true)
  end

end