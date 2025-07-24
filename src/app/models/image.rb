class Image < ApplicationRecord
  belongs_to :account, optional: true
  attribute :meta, :json, default: {}
  enum :status, { normal: 0, locked: 1 }

  after_initialize :set_aid, if: :new_record? # before_create :set_aidだと画像のpathにaidを入れられない
  before_save :image_upload
  attr_accessor :image

  validate :image_varidation

  def image_url(variant_type: "images")
    if self.original_key.present?
      unless self.variants.include?(variant_type)
        process_image(variant_type: variant_type)
        self.save
      end
      return signed_object_url(key: "/variants/#{variant_type}/images/#{self.aid}.webp")
    else
      return "/statics/images/bealive-logo.png"
    end
  end

  private

  def image_upload
    if image
      if self.original_key.present?
        delete_variants()
        s3_delete(key: self.original_key)
      end
      extension = image.original_filename.split(".").last.downcase
      key = "/images/#{self.aid}.#{extension}"
      self.original_key = key
      s3_upload(
        key: key,
        file: self.image.path,
        content_type: self.image.content_type
      )
    end
  end

  def image_varidation
    varidate_image() if self.original_key.blank?
  end
end
