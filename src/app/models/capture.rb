class Capture < ApplicationRecord
  belongs_to :sender, foreign_key: "sender_id", class_name: "Account"
  belongs_to :receiver, foreign_key: "receiver_id", class_name: "Account", optional: true

  attribute :meta, :json, default: {}
  enum :status, { normal: 0, locked: 1 }
  enum :visibility, {
    public: 0,
    followers_only: 1,
    group_only: 2,
    link_only: 3,
    private: 4
  }, prefix: true
  attr_accessor :front_image
  attr_accessor :back_image
  attr_accessor :image
  attr_accessor :upload

  before_create :set_aid
  before_save :image_upload

  validate :image_type_and_required, if: :upload
  validates :comment, length: { in: 1..255, allow_blank: true }

  def front_image_url(variant_type: "bealive_capture")
    variants = []
    if self.front_variants.present?
      variants =JSON.parse(self.front_variants)
    end
    unless variants.include?(variant_type)
      return "/statics/images/bealive-1.png"
    end
    return signed_object_url(key: "/variants/#{variant_type}/front_images/#{self.aid}.webp")
  end

  def back_image_url(variant_type: "bealive_capture")
    variants = []
    if self.back_variants.present?
      variants =JSON.parse(self.back_variants)
    end
    unless variants.include?(variant_type)
      return "/statics/images/bealive-1.png"
    end
    return signed_object_url(key: "/variants/#{variant_type}/back_images/#{self.aid}.webp")
  end

  def variants_delete
    delete_variants()# aaa
  end

  def image_delete
    delete_image()# aaa
  end

  private

  def image_type_and_required
    varidate_image(column_name: "front_image", required: true)
    varidate_image(column_name: "back_image", required: true)
  end

  def image_upload
    if front_image
      extension = front_image.original_filename.split(".").last.downcase
      key = "/front_images/#{self.aid}.#{extension}"
      process_image(
        variant_type: "bealive_capture", image_type: "front_images",
        variants_column: "front_variants", original_key_column: "front_original_key",
        original_image_path: front_image.path
      )
    end
    if back_image
      extension = back_image.original_filename.split(".").last.downcase
      key = "/back_images/#{self.aid}.#{extension}"
      process_image(
        variant_type: "bealive_capture", image_type: "back_images",
        variants_column: "back_variants", original_key_column: "back_original_key",
        original_image_path: back_image.path
      )
    end
  end

end
