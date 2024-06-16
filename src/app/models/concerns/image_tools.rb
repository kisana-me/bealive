module ImageTools

  private

  def process_image(variant_type: 'images', image_type: 'images', variants_column: 'variants', original_key_column: 'original_key', original_image_path: '')
    if self.send(variants_column).present?
      variants =JSON.parse(self.send(variants_column))
      if variants.include?(variant_type)
        return
      end
    end
    s3 = Aws::S3::Client.new(
      endpoint: ENV["S3_LOCAL_ENDPOINT"],
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_USER"],
      secret_access_key: ENV["S3_PASSWORD"],
      force_path_style: true
    )
    if original_image_path.blank?
      downloaded_image = Tempfile.new(['downloaded_image'])
      original_image_path = downloaded_image.path
      s3.get_object(bucket: ENV["S3_BUCKET"], key: self.send(original_key_column), response_target: original_image_path)
    end
    converted_image = Tempfile.new(['converted_image'])
    resize = "2048x2048>"
    extent = "" # 切り取る
    case variant_type
    # icon
    when 'icons'
      resize = "400x400^"
      extent = "400x400"
    when 'tb-icons'
      resize = "50x50^"
      extent = "50x50"
    # banner
    when 'banners'
      resize = "1600x1600^"
      extent = "1600x1600"
    when 'tb-banners'
      resize = "400x400^"
      extent = "400x400"
    # image
    when 'images'
      resize = "2048x2048>"
    when 'tb-images'
      resize = "700x700>"
    when '4k-images'
      resize = "4096x4096>"
    # emoji
    when 'emojis'
      resize = "200x200>"
    when 'tb-emojis'
      resize = "50x50>"
    end
    image = MiniMagick::Image.open(original_image_path)
    if image.frames.count > 1
      processed = ImageProcessing::MiniMagick
        .source(original_image_path)
        .loader(page: nil)
        .coalesce
        .gravity("center")
        .resize(resize)
        .then do |chain|
          if extent.present?
            chain.extent(extent)
          else
            chain
          end
        end
        .strip
        .auto_orient
        .quality(85)
        .convert("webp")
        .call(destination: converted_image.path)
    else
      image = MiniMagick::Image.open(original_image_path)
      image.format('webp')
      image = image.coalesce
      image.combine_options do |img|
        img.gravity "center"
        img.quality 85
        #img.auto_orient
        img.strip # EXIF削除
        img.resize resize
        unless extent == ''
          img.extent extent
        end
      end
      image.write(converted_image.path)
    end
    key = "/variants/#{variant_type}/#{image_type}/#{self.uuid}.webp"
    s3_upload(key: key, file: converted_image.path, content_type: 'image/webp')
    add_mca_data(self, variants_column, [variant_type], false)
    if downloaded_image
      downloaded_image.close
    end
    converted_image.close
  end

  def delete_variants(variants_column: 'variants', image_type: 'images')
    arr = JSON.parse(self.send(variants_column))
    arr.each do |variant_type|
      s3_delete(key: "/variants/#{variant_type}/#{image_type}/#{self.uuid}.webp")
    end
    remove_mca_data(self, variants_column, arr, false)
  end

  def delete_image(original_key_column: 'original_key', variants_column: 'variants', image_type: 'images')
    delete_variants(variants_column: variants_column, image_type: image_type)
    s3_delete(key: self.send(original_key_column))
    self.update(original_key_column.to_sym => '')
  end

  def varidate_image(column_name: 'image', required: true)
    file = self.send(column_name)
    if file
      begin
        image = MiniMagick::Image.read(file)
        allowed_content_types = ['image/png', 'image/jpeg', 'image/gif', 'image/webp']
        unless allowed_content_types.include?(image.mime_type)
          errors.add(column_name.to_sym, "未対応の形式です")
        end
      rescue MiniMagick::Invalid
        errors.add(column_name.to_sym, "無効な画像ファイルです")
      end
    elsif required
      errors.add(column_name.to_sym, "画像がありません")
    end
  end
end