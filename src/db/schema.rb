# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 10) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "aid", limit: 14, null: false
    t.string "name", null: false
    t.string "name_id", null: false
    t.text "description", default: "", null: false
    t.datetime "birthdate"
    t.string "email"
    t.boolean "email_verified", default: false, null: false
    t.integer "visibility", limit: 1, default: 0, null: false
    t.string "password_digest"
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "icon_id"
    t.index ["aid"], name: "index_accounts_on_aid", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["icon_id"], name: "index_accounts_on_icon_id"
    t.index ["name_id"], name: "index_accounts_on_name_id", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "captures", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "aid", limit: 14, null: false
    t.bigint "sender_id", null: false
    t.bigint "receiver_id"
    t.bigint "parent_capture_id"
    t.bigint "group_id"
    t.bigint "main_photo_id"
    t.bigint "sub_photo_id"
    t.decimal "latitude", precision: 10
    t.decimal "longitude", precision: 10
    t.string "sender_comment"
    t.string "receiver_comment"
    t.datetime "captured_at"
    t.integer "visibility", limit: 1, default: 0, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aid"], name: "index_captures_on_aid", unique: true
    t.index ["group_id"], name: "index_captures_on_group_id"
    t.index ["main_photo_id"], name: "index_captures_on_main_photo_id"
    t.index ["parent_capture_id"], name: "index_captures_on_parent_capture_id"
    t.index ["receiver_id"], name: "index_captures_on_receiver_id"
    t.index ["sender_id"], name: "index_captures_on_sender_id"
    t.index ["sub_photo_id"], name: "index_captures_on_sub_photo_id"
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "capture_id", null: false
    t.string "aid", limit: 14, null: false
    t.string "name"
    t.string "content", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_comments_on_account_id"
    t.index ["aid"], name: "index_comments_on_aid", unique: true
    t.index ["capture_id"], name: "index_comments_on_capture_id"
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "entries", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "group_id", null: false
    t.boolean "accepted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "group_id"], name: "index_entries_on_account_id_and_group_id", unique: true
    t.index ["account_id"], name: "index_entries_on_account_id"
    t.index ["group_id"], name: "index_entries_on_group_id"
  end

  create_table "follows", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "followed_id", null: false
    t.bigint "follower_id", null: false
    t.boolean "accepted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id", "follower_id"], name: "index_follows_on_followed_id_and_follower_id", unique: true
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "groups", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "icon_id"
    t.string "aid", null: false
    t.string "name", default: "", null: false
    t.text "description", default: "", null: false
    t.integer "visibility", limit: 1, default: 0, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_groups_on_account_id"
    t.index ["aid"], name: "index_groups_on_aid", unique: true
    t.index ["icon_id"], name: "index_groups_on_icon_id"
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "images", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.string "aid", limit: 14, null: false
    t.string "name", default: "", null: false
    t.text "description", default: "", null: false
    t.string "original_ext", null: false
    t.text "variants", size: :long, default: "[]", null: false, collation: "utf8mb4_bin"
    t.integer "visibility", limit: 1, default: 0, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_images_on_account_id"
    t.index ["aid"], name: "index_images_on_aid", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
    t.check_constraint "json_valid(`variants`)", name: "variants"
  end

  create_table "oauth_accounts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "aid", limit: 14, null: false
    t.bigint "account_id", null: false
    t.integer "provider", limit: 1, null: false
    t.string "uid", null: false
    t.text "access_token", null: false
    t.text "refresh_token", null: false
    t.datetime "expires_at", null: false
    t.datetime "fetched_at", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_oauth_accounts_on_account_id"
    t.index ["aid"], name: "index_oauth_accounts_on_aid", unique: true
    t.index ["provider", "uid"], name: "index_oauth_accounts_on_provider_and_uid", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "aid", limit: 14, null: false
    t.bigint "account_id", null: false
    t.string "name", default: "", null: false
    t.string "token_lookup", null: false
    t.string "token_digest", null: false
    t.datetime "token_expires_at", null: false
    t.datetime "token_generated_at", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sessions_on_account_id"
    t.index ["aid"], name: "index_sessions_on_aid", unique: true
    t.index ["token_lookup"], name: "index_sessions_on_token_lookup", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  add_foreign_key "accounts", "images", column: "icon_id"
  add_foreign_key "captures", "accounts", column: "receiver_id"
  add_foreign_key "captures", "accounts", column: "sender_id"
  add_foreign_key "captures", "captures", column: "parent_capture_id"
  add_foreign_key "captures", "groups"
  add_foreign_key "captures", "images", column: "main_photo_id"
  add_foreign_key "captures", "images", column: "sub_photo_id"
  add_foreign_key "comments", "accounts"
  add_foreign_key "comments", "captures"
  add_foreign_key "entries", "accounts"
  add_foreign_key "entries", "groups"
  add_foreign_key "follows", "accounts", column: "followed_id"
  add_foreign_key "follows", "accounts", column: "follower_id"
  add_foreign_key "groups", "accounts"
  add_foreign_key "groups", "images", column: "icon_id"
  add_foreign_key "images", "accounts"
  add_foreign_key "oauth_accounts", "accounts"
  add_foreign_key "sessions", "accounts"
end
