class Capture < ApplicationRecord
  enum visibility: { public_visibility: 0, follow_visibility: 1, group_visibility: 2, follow_group_visibility: 3, party_visibility: 4 }
  enum status: { waiting: 0, done: 1 }
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Account'
  belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Account', optional: true

  validate :image_type_and_required, if: :upload
  attr_accessor :front_image
  attr_accessor :back_image
  before_update :image_upload
  attr_accessor :image
  attr_accessor :upload

  def image_upload
    if front_image
      extension = front_image.original_filename.split('.').last.downcase
      key = "/front_images/#{self.uuid}.#{extension}"
      process_image(
        variant_type: 'images', image_type: 'front_images',
        variants_column: 'front_variants', original_key_column: 'front_original_key',
        original_image_path: front_image.path
      )
    end
    if back_image
      extension = back_image.original_filename.split('.').last.downcase
      key = "/back_images/#{self.uuid}.#{extension}"
      process_image(
        variant_type: 'images', image_type: 'back_images',
        variants_column: 'back_variants', original_key_column: 'back_original_key',
        original_image_path: back_image.path
      )
    end
  end
  def front_image_url(variant_type: 'images')
    variants = []
    if self.front_variants.present?
      variants =JSON.parse(self.front_variants)
    end
    unless variants.include?(variant_type)
      return '/images/bealive-image-169.webp'
    end
    return signed_object_url(key: "/variants/#{variant_type}/front_images/#{self.uuid}.webp")
  end
  def back_image_url(variant_type: 'images')
    variants = []
    if self.back_variants.present?
      variants =JSON.parse(self.back_variants)
    end
    unless variants.include?(variant_type)
      return '/images/bealive-image-169.webp'
    end
    return signed_object_url(key: "/variants/#{variant_type}/back_images/#{self.uuid}.webp")
  end
  def variants_delete
    delete_variants()# aaa
  end
  def image_delete
    delete_image()# aaa
  end

  private

  def image_type_and_required
    varidate_image(column_name: 'front_image', required: true)
    varidate_image(column_name: 'back_image', required: true)
  end
end
