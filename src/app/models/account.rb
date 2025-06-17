class Account < ApplicationRecord
  has_many :sender, class_name: "Capture", foreign_key: "sender_id"
  has_many :receiver, class_name: "Capture", foreign_key: "receiver_id"
  has_many :invitations
  belongs_to :invitation, optional: true
  belongs_to :icon, class_name: "Image", foreign_key: "icon_id", optional: true

  # followに関して

  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id"
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, class_name: "Follow", foreign_key: "followed_id"
  has_many :followers, through: :passive_follows, source: :follower

  # 許可されたフォロワーのリストを取得するメソッド
  # これは「自分がフォローされている側」で、かつ「accepted: true」であるフォロワー
  has_many :accepted_passive_follows, -> { where(accepted: true) },
           class_name: "Follow", foreign_key: "followed_id", dependent: :destroy
  has_many :accepted_followers, through: :accepted_passive_follows, source: :follower

  # 許可された「自分がフォローしている」ユーザーのリストを取得するメソッド
  # これは「自分がフォローしている側」で、かつ「accepted: true」であるフォロー
  has_many :accepted_active_follows, -> { where(accepted: true) },
           class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :accepted_following, through: :accepted_active_follows, source: :followed

  # === #

  enum :status, { normal: 0, locked: 1 }
  attribute :meta, :json, default: {}
  attr_accessor :icon_uuid

  before_validation :assign_icon
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

  # followに関して

  # 特定のユーザーをフォローするメソッド
  def follow(other_account)
    active_follows.create(followed_id: other_account.id)
  end

  # 特定のユーザーのフォローを解除するメソッド
  def unfollow(other_account)
    active_follows.find_by(followed_id: other_account.id).destroy
  end

  # あるユーザーがこのユーザーをフォローしているかチェックするメソッド
  def following?(other_account)
    following.include?(other_account)
  end

  # フォローリクエストを承認するメソッド
  def accept_follow(follower_account)
    passive_follows.find_by(follower_id: follower_account.id)&.update(accepted: true)
  end

  # フォローリクエストを拒否する（または削除する）メソッド
  def decline_follow(follower_account)
    passive_follows.find_by(follower_id: follower_account.id)&.destroy
  end

  # 特定のユーザーからのフォローが承認されているかチェックするメソッド
  def has_accepted_follower?(follower_account)
    accepted_followers.include?(follower_account)
  end

  # === #

  def icon_url
    if icon
      icon.image_url(variant_type: "icons")
    else
      return "/statics/images/bealive-logo.png"
    end
  end

  private

  def generate_aid
    self.aid ||= SecureRandom.base36(14)
  end

  def assign_icon
    return if icon_uuid.blank?
    self.icon = Image.find_by(account: self, uuid: icon_uuid, deleted: false)
  end
end
