class Image < ApplicationRecord
  belongs_to :account, optional: true
  attribute :variants, :json, default: []
  attribute :meta, :json, default: {}
  enum :status, { normal: 0, locked: 1 }

  after_initialize :set_aid, if: :new_record? # before_create :set_aidだと画像のpathにaidを入れられない
  before_create :image_upload
  attr_accessor :image

  validate :image_varidation

  def image_url(variant_type: "images")
    unless variants.include?(variant_type)
      return "/statics/images/bealive-logo.png" unless self.original_ext.present?
      process_image(variant_type: variant_type)
      self.save
    end
    return signed_object_url(key: "/images/variants/#{variant_type}/#{self.aid}.webp")
  end

  private

  def image_upload
    extension = image.original_filename.split(".").last.downcase
    self.original_ext = extension
    s3_upload(
      key: "/images/#{self.aid}.#{extension}",
      file: self.image.path,
      content_type: self.image.content_type
    )
  end

  def image_varidation
    return unless new_record?
    varidate_image(required: true)
  end
end
