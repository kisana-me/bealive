# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Account.create!(
  aid: "00000000000000",
  anyur_id: "00000000000000",
  name: "kisana",
  name_id: "kisana",
  email: "kisana@kisana.me",
  email_verified: true,
  roles: "admin"
)

30.times do |index|
  num = index + 1
  Capture.create!(
    sender: Account.first,
    uuid: SecureRandom.uuid,
    front_image: ActionDispatch::Http::UploadedFile.new(
      filename: "front_image_#{num}",
      type: "image/png",
      tempfile: File.open(Rails.root.join("db", "seed_images", "#{num}-f.png"))),
    back_image: ActionDispatch::Http::UploadedFile.new(
      filename: "back_image_#{num}",
      type: "image/png",
      tempfile: File.open(Rails.root.join("db", "seed_images", "#{num}-b.png"))),
    captured_at: Time.current,
    status: 1
  )
end