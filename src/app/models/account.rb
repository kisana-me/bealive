class Account < ApplicationRecord
  has_secure_password
  has_many :sender, class_name: 'Capture', foreign_key: 'sender_id'
  has_many :receiver, class_name: 'Capture', foreign_key: 'receiver_id'
  has_many :invitations
  belongs_to :invitation, optional: true
  enum status: { normal: 0, suspended: 1 }
  serialize :meta, JSON

  BASE_64_URL_REGEX  = /\A[a-zA-Z0-9_-]*\z/
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :name_id,
    presence: true,
    length: { in: 5..50, allow_blank: true },
    format: { with: BASE_64_URL_REGEX, allow_blank: true },
    uniqueness: { case_sensitive: false }
  validates :email,
    length: { maximum: 255, allow_blank: true },
    format: { with: VALID_EMAIL_REGEX, allow_blank: true },
    uniqueness: { case_sensitive: false, allow_blank: true }
  validates :password,
    presence: true,
    length: { in: 8..63, allow_blank: true },
    allow_nil: true
end
