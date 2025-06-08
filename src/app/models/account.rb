class Account < ApplicationRecord
  has_many :sender, class_name: "Capture", foreign_key: "sender_id"
  has_many :receiver, class_name: "Capture", foreign_key: "receiver_id"
  has_many :invitations
  belongs_to :invitation, optional: true

  enum :status, { normal: 0, locked: 1 }
  attribute :meta, :json, default: {}

  before_create :generate_aid

  BASE_64_URL_REGEX  = /\A[a-zA-Z0-9_-]*\z/
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :name,
    presence: true,
    length: { in: 1..50, allow_blank: true }
  validates :name_id,
    presence: true,
    length: { in: 5..50, allow_blank: true },
    format: { with: BASE_64_URL_REGEX, allow_blank: true },
    uniqueness: { case_sensitive: false }
  validates :email,
    length: { maximum: 255, allow_blank: true },
    format: { with: VALID_EMAIL_REGEX, allow_blank: true },
    uniqueness: { case_sensitive: false, allow_blank: true }
  validates :password, length: { in: 8..63, allow_blank: true }
  has_secure_password validations: false

  def remember(ip, ua)
    session = Session.new(account: self, ip_address: ip, user_agent: ua)
    token = generate_base36
    lookup = generate_lookup(token)
    digest = generate_digest(token)
    session.token_lookup = lookup
    session.token_digest = digest
    return token if session.save
  end

  def self.find_by_session(token)
    lookup = new.generate_lookup(token)
    db_session = Session.find_by(token_lookup: lookup, status: 0, deleted: false)
    return nil unless db_session
    return nil unless BCrypt::Password.new(db_session.token_digest).is_password?(token)
    db_session.account
  end

  private

  def generate_aid
    self.aid ||= SecureRandom.base36(14)
  end

end
