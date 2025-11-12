class Capture < ApplicationRecord
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Account'
  belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Account', optional: true

  belongs_to :main_photo, class_name: 'Image', foreign_key: 'main_photo_id', optional: true
  belongs_to :sub_photo, class_name: 'Image', foreign_key: 'sub_photo_id', optional: true
  accepts_nested_attributes_for :main_photo, :sub_photo

  attribute :meta, :json, default: -> { {} }
  enum :visibility, { closed: 0, limited: 1, opened: 2, followers_only: 3, group_only: 4 }, default: :limited
  enum :status, { normal: 0, locked: 1, deleted: 2 }
  attr_accessor :upload_photo

  before_create :set_aid

  validates :sender_comment, length: { in: 1..255, allow_blank: true }
  validates :receiver_comment, length: { in: 1..255, allow_blank: true }
  validates :main_photo, :sub_photo, presence: true, if: :upload_photo

  scope :is_normal, -> { where(status: :normal) }
  scope :isnt_deleted, -> { where.not(status: :deleted) }
  scope :is_opened, -> { where(visibility: :opened) }
  scope :isnt_closed, -> { where.not(visibility: :closed) }

  scope :is_captured, -> { where.not(captured_at: nil) }
  scope :isnt_captured, -> { where(captured_at: nil) }
  scope :sent_captures, -> {
    where(status: :normal)
    .joins('INNER JOIN accounts AS senders ON senders.id = captures.sender_id AND senders.status = 0')
    .joins('LEFT JOIN accounts AS receivers ON receivers.id = captures.receiver_id')
    .where('captures.receiver_id IS NULL OR receivers.status = 0')
    .includes(:main_photo, :sub_photo, sender: :icon, receiver: :icon)
    .order(captured_at: :desc)
  }

  def main_photo_url
    self.main_photo&.image_url(variant_type: 'bealive_capture') || '/statics/images/bealive-1.png'
  end

  def sub_photo_url
    self.sub_photo&.image_url(variant_type: 'bealive_capture') || '/statics/images/bealive-1.png'
  end

  def owner
    self.receiver ? self.receiver : self.sender
  end

  private
end
