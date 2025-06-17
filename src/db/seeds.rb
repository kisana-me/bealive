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
    front_image: ActionDispatch::Http::UploadedFile.new(
      filename: "front_image_#{num}",
      type: "image/png",
      tempfile: File.open(Rails.root.join("db", "seed_images", "#{num}-f.webp"))),
    back_image: ActionDispatch::Http::UploadedFile.new(
      filename: "back_image_#{num}",
      type: "image/png",
      tempfile: File.open(Rails.root.join("db", "seed_images", "#{num}-b.webp"))),
    captured_at: Time.zone.local(2025, 6, 8, 15, 0) + num.minutes,
    status: 1,
    created_at: Time.zone.local(2025, 6, 8, 15, 0),
    updated_at: Time.zone.local(2025, 6, 8, 15, 0)
  )
end
