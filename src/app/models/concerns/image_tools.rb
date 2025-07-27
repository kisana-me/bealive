module ImageTools
  # ver 1.0.0
  # images/variants/[variant_type]/[aid].[ext]
  # images/originals/[aid].[ext]
  # original_ext(string)とvariants(json)が必要

  include S3Tools

  private

  def process_image(
    variant_type: "images",
    variants_column: "variants",
    original_ext_column: "original_ext",
    original_image_path: nil
  )
    return if self.send(variants_column).include?(variant_type)
    if original_image_path.blank?
      downloaded_image = Tempfile.new(["downloaded_image"])
      original_image_path = downloaded_image.path
      s3_download(key: "/images/originals/#{self.aid}.#{self.send(original_ext_column)}", response_target: original_image_path)
    end
    converted_image = Tempfile.new(["converted_image"])
    resize = "2048x2048>"
    extent = "" # 切り取る
    case variant_type
    # bealive
    when "bealive_capture"
      resize = "600x800^"
      extent = "600x800"
    # icon
    when "icons"
      resize = "400x400^"
      extent = "400x400"
    when "tb-icons"
      resize = "50x50^"
      extent = "50x50"
    # banner
    when "banners"
      resize = "1600x1600^"
      extent = "1600x1600"
    when "tb-banners"
      resize = "400x400^"
      extent = "400x400"
    # image
    when "images"
      resize = "2048x2048>"
    when "tb-images"
      resize = "700x700>"
    when "4k-images"
      resize = "4096x4096>"
    # emoji
    when "emojis"
      resize = "200x200>"
    when "tb-emojis"
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
      image.format("webp")
      image = image.coalesce
      image.combine_options do |img|
        img.gravity "center"
        img.quality 85
        #img.auto_orient
        img.strip # EXIF削除
        img.resize resize
        img.extent extent unless extent.blank?
      end
      image.write(converted_image.path)
    end
    key = "/images/variants/#{variant_type}/#{self.aid}.webp"
    s3_upload(key: key, file: converted_image.path, content_type: "image/webp")
    # add_mca_data(self, variants_column, [variant_type], false)
    self.send(variants_column) << variant_type
    downloaded_image.close if downloaded_image
    converted_image.close
  end



  def delete_original()
  end



  def delete_variants(variants_column: "variants")
    arr = JSON.parse(self.send(variants_column))
    arr.each do |variant_type|
      s3_delete(key: "/variants/#{variant_type}/#{image_type}/#{self.aid}.webp")
    end
    remove_mca_data(self, variants_column, arr, false)
  end



  def delete_image(
    original_key_column: "original_key",
    variants_column: "variants",
    image_type: "images"
  )
    delete_variants(variants_column: variants_column, image_type: image_type)
    s3_delete(key: self.send(original_key_column))
    self.update(original_key_column.to_sym => "")
  end



  def varidate_image(
    column_name: "image",
    required: true,
    max_size_mb: 30,
    max_width: 4096,
    max_height: 4096
  )
    file = self.send(column_name)
    return errors.add(column_name.to_sym, :image_blank) if required && !file
    begin
      image = MiniMagick::Image.read(file)

      # 拡張子チェック
      allowed_content_types = ["image/png", "image/jpeg", "image/gif", "image/webp"]
      unless allowed_content_types.include?(image.mime_type)
        errors.add(column_name.to_sym, :image_invalid_format)
      end

      # 容量チェック
      size_in_mb = (file.size.to_f / 1024 / 1024).round(2)
      if size_in_mb > max_size_mb
        errors.add(column_name.to_sym, :image_too_large, max_size_mb: max_size_mb)
      end

      # 解像度チェック
      if image.width > max_width || image.height > max_height
        errors.add(column_name.to_sym, :image_dimensions_exceeded, max_width: max_width, max_height: max_height)
      end

    rescue MiniMagick::Invalid
      errors.add(column_name.to_sym, :image_invalid)
    end
  end
end