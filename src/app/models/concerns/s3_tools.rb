module S3Tools
  # ver 1.0.0

  require "aws-sdk-s3"

  private

  def object_url(key: "")
    bucket_key = File.join(ENV["S3_BUCKET"], key)
    url = File.join(ENV["S3_PUBLIC_ENDPOINT"], bucket_key)
    return url
  end

  def signed_object_url(key: "", expires_in: 100)
    s3 = Aws::S3::Client.new(
      endpoint: ENV["S3_PUBLIC_ENDPOINT"],
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_USERNAME"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    signer = Aws::S3::Presigner.new(client: s3)
    signer.presigned_url(
      :get_object,
      bucket: ENV["S3_BUCKET"],
      key: key.to_s.gsub(%r{^/}, ""),
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
      access_key_id: ENV["S3_USERNAME"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    obj = s3.bucket(ENV["S3_BUCKET"]).object(key)
    obj.upload_file(file, content_type: content_type, acl: "readonly")
  end

  def s3_download(key:, response_target:)
    s3 = Aws::S3::Client.new(
      endpoint: ENV["S3_LOCAL_ENDPOINT"],
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_USERNAME"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    s3.get_object(bucket: ENV["S3_BUCKET"], key: key, response_target: response_target)
  end

  def s3_delete(key:)
    s3 = Aws::S3::Client.new(
      endpoint: ENV["S3_LOCAL_ENDPOINT"],
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_USERNAME"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    s3.delete_object(bucket: ENV["S3_BUCKET"], key: key)
  end
end