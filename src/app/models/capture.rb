class Capture < ApplicationRecord
  #enum visibility: { public_visibility: 0, follow_visibility: 1, group_visibility: 2, account_visibility: 3 }
  enum status: { done: 0, waiting: 1 }
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
      if self.front_original_key.present?
        delete_variants()# aaa
        s3_delete(key: self.front_original_key)
      end
        extension = front_image.original_filename.split('.').last.downcase
        key = "/front_images/#{self.uuid}.#{extension}"
        self.front_original_key = key
        s3_upload(key: key, file: self.front_image.path, content_type: self.front_image.content_type)
    end
    if back_image
      if self.back_original_key.present?
        delete_variants()# aaa
        s3_delete(key: self.back_original_key)
      end
        extension = back_image.original_filename.split('.').last.downcase
        key = "/back_images/#{self.uuid}.#{extension}"
        self.back_original_key = key
        s3_upload(key: key, file: self.back_image.path, content_type: self.back_image.content_type)
    end
  end
  def front_image_url(variant_type: 'images')
    if self.front_original_key.present?
      variants = []
      if self.front_variants.present?
        variants =JSON.parse(self.front_variants)
      end
      unless variants.include?(variant_type)
        process_image(variant_type: variant_type, image_type: 'front_images', variants_column: 'front_variants', original_key_column: 'front_original_key')
        # variant_type: 'images', image_type: 'images', variants_column: 'variants', original_key_column: 'original_key'
      end
      return object_url(key: "/variants/#{variant_type}/front_images/#{self.uuid}.webp")
    else
      return '/'
    end
  end
  def back_image_url(variant_type: 'images')
    if self.back_original_key.present?
      variants = []
      if self.back_variants.present?
        variants =JSON.parse(self.back_variants)
      end
      unless variants.include?(variant_type)
        process_image(variant_type: variant_type, image_type: 'back_images', variants_column: 'back_variants', original_key_column: 'back_original_key')
      end
      return object_url(key: "/variants/#{variant_type}/back_images/#{self.uuid}.webp")
    else
      return '/'
    end
  end
  def variants_delete
    delete_variants()# aaa
  end
  def image_delete
    delete_image()# aaa
  end

  private

  def image_type_and_required
    Rails.logger.info("~~~~~~~~~~~~~~~~^^^^^")
    varidate_image(column_name: 'front_image', required: true)
    varidate_image(column_name: 'back_image', required: true)
  end
end
