class Capture < ApplicationRecord
  belongs_to :sender, foreign_key: "sender_id", class_name: "Account"
  belongs_to :receiver, foreign_key: "receiver_id", class_name: "Account", optional: true

  belongs_to :front_photo, class_name: "Image", foreign_key: "front_photo_id", optional: true, dependent: :destroy
  belongs_to :back_photo, class_name: "Image", foreign_key: "back_photo_id", optional: true, dependent: :destroy
  accepts_nested_attributes_for :front_photo, :back_photo

  attribute :meta, :json, default: {}
  enum :status, { normal: 0, locked: 1 }
  enum :visibility, {
    public: 0,
    followers_only: 1,
    group_only: 2,
    link_only: 3,
    private: 4
  }, prefix: true, default: :link_only
  attr_accessor :upload_photo

  before_create :set_aid

  validates :sender_comment, length: { in: 1..255, allow_blank: true }
  validates :receiver_comment, length: { in: 1..255, allow_blank: true }
  validates :front_photo, :back_photo, presence: true, if: :upload_photo

  default_scope {
    where(deleted: false)
    .joins("INNER JOIN accounts AS senders ON senders.id = captures.sender_id AND senders.deleted = false")
    .joins("LEFT JOIN accounts AS receivers ON receivers.id = captures.receiver_id")
    .where("captures.receiver_id IS NULL OR receivers.deleted = false")
    .includes(:front_photo, :back_photo, sender: :icon, receiver: :icon)
    .order(captured_at: :desc)
  }
  scope :captured, -> {
    where.not(captured_at: nil)
  }

  def front_photo_url()
    self.front_photo&.image_url(variant_type: "bealive_capture") || "/statics/images/bealive-1.png"
  end

  def back_photo_url()
    self.back_photo&.image_url(variant_type: "bealive_capture") || "/statics/images/bealive-1.png"
  end

  def owner
    self.receiver ? self.receiver : self.sender
  end

  private

end
