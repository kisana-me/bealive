class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  require 'aws-sdk-s3'
  include ImageTools

  def generate_base36(length = 128)
    SecureRandom.base36(length)
  end

  def generate_lookup(token, length = 36)
    Digest::SHA256.hexdigest(token)[ 0 ... length ]
  end

  def generate_digest(token)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(token, cost: cost)
  end

  def read_include(column: 'info', obj:)
    if self[column.to_sym].present?
      mca_array = JSON.parse(object[column.to_sym])
      return mca_array.include?(obj)
    else
      return false
    end
  end

  private

  #object.update(column.to_sym => mca_array.to_json)
  def add_mca_data(object, column, add_mca_array, save = false)
    if object[column.to_sym].present?
      mca_array = JSON.parse(object[column.to_sym])
    else
      mca_array = []
    end
    add_mca_array.each do |obj|
      mca_array.push(obj)
    end
    object[column.to_sym] = mca_array.to_json
    if save
      object.save!
    end
  end
  def remove_mca_data(object, column, remove_mca_array, save = false)
    if object[column.to_sym].present?
      mca_array = JSON.parse(object[column.to_sym])
    else
      mca_array = []
    end
    remove_mca_array.each do |obj|
      mca_array.delete(obj)
    end
    object[column.to_sym] = mca_array.to_json
    if save
      object.save
    end
  end

  def object_url(key: '')
    bucket_key = File.join(ENV["S3_BUCKET"], key)
    url = File.join(ENV["S3_PUBLIC_ENDPOINT"], bucket_key)
    return url
  end

  def signed_object_url(key: '', expires_in: 100)
    s3 = Aws::S3::Client.new(
      endpoint: ENV["S3_PUBLIC_ENDPOINT"],
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_USER"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    signer = Aws::S3::Presigner.new(client: s3)
    signer.presigned_url(
      :get_object,
      bucket: ENV["S3_BUCKET"],
      key: "#{key}",
      expires_in: expires_in
    )
  rescue => e
    Rails.logger.error("Failed to generate signed URL: #{e.message}")
    nil
  end

  def s3_upload(key:, file:, content_type:)
    s3 = Aws::S3::Resource.new(
      endpoint: ENV["S3_LOCAL_ENDPOINT"],
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_USER"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    obj = s3.bucket(ENV["S3_BUCKET"]).object(key)
    obj.upload_file(file, content_type: content_type, acl: 'readonly')
  end
  def s3_delete(key:)
    s3 = Aws::S3::Client.new(
      endpoint: ENV["S3_LOCAL_ENDPOINT"],
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_USER"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    s3.delete_object(bucket: ENV["S3_BUCKET"], key: key)
  end
end
