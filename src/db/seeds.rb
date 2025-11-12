Account.create!(
  aid: "00000000000000",
  name: "kisana",
  name_id: "kisana",
  email: "kisana@kisana.me",
  email_verified: true,
  visibility: 2,
  meta: { roles: "admin" }
)

30.times do |index|
  num = index + 1
  capture = Capture.create!(
    sender: Account.first,
    visibility: 2,
    created_at: Time.zone.local(2025, 6, 8, 15, 0),
    updated_at: Time.zone.local(2025, 6, 8, 15, 0)
  )
  capture.update!(
    receiver: Account.first,
    main_photo_attributes: {
      image: ActionDispatch::Http::UploadedFile.new(
        filename: "main_image_#{num}.webp",
        type: "image/png",
        tempfile: File.open(Rails.root.join("db", "seed_images", "#{num}-f.webp"))
      )
    },
    sub_photo_attributes: {
      image: ActionDispatch::Http::UploadedFile.new(
        filename: "sub_image_#{num}.webp",
        type: "image/png",
        tempfile: File.open(Rails.root.join("db", "seed_images", "#{num}-b.webp"))
      )
    },
    captured_at: Time.zone.local(2025, 6, 8, 15, 0) + num.minutes
  )
end
