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

ActiveRecord::Schema[7.1].define(version: 2024_06_15_025436) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "name_id", null: false
    t.string "uuid", null: false
    t.text "description", default: "", null: false
    t.datetime "birth"
    t.string "email", default: "", null: false
    t.string "phone", default: "", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.string "password_digest", default: "", null: false
    t.bigint "icon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_id", "uuid"], name: "index_accounts_on_name_id_and_uuid", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "captures", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id"
    t.bigint "group_id"
    t.string "uuid", null: false
    t.string "front_original_key", default: "", null: false
    t.string "front_variants", default: "", null: false
    t.string "back_original_key", default: "", null: false
    t.string "back_variants", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "captured_at"
    t.integer "visibility", limit: 1, default: 0, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.boolean "deleted", default: false, null: false
    t.decimal "latitude", precision: 10
    t.decimal "longitude", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_captures_on_group_id"
    t.index ["receiver_id"], name: "fk_rails_436bbf3df3"
    t.index ["sender_id"], name: "fk_rails_ce2cf603f1"
    t.index ["uuid"], name: "index_captures_on_uuid", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "capture_id", null: false
    t.string "uuid", null: false
    t.string "content", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_comments_on_account_id"
    t.index ["capture_id"], name: "index_comments_on_capture_id"
    t.index ["uuid"], name: "index_comments_on_uuid", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "entries", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "group_id", null: false
    t.string "uuid", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_entries_on_account_id"
    t.index ["group_id"], name: "index_entries_on_group_id"
  end

  create_table "follows", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "followed_id", null: false
    t.bigint "follower_id", null: false
    t.string "uuid", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "fk_rails_5ef72a3867"
    t.index ["follower_id"], name: "fk_rails_622d34a301"
  end

  create_table "groups", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", null: false
    t.string "name", default: "", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.boolean "deleted", default: false, null: false
    t.bigint "icon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_groups_on_account_id"
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "images", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.string "uuid", null: false
    t.string "name", default: "", null: false
    t.string "original_key", default: "", null: false
    t.string "variants", default: "", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_images_on_account_id"
    t.index ["uuid"], name: "index_images_on_uuid", unique: true
  end

  create_table "inquiries", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "subject", default: "", null: false
    t.text "content", default: "", null: false
    t.string "name", default: "", null: false
    t.string "address", default: "", null: false
    t.text "memo", default: "", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_inquiries_on_uuid", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "invitations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.string "code"
    t.integer "uses"
    t.integer "max_uses"
    t.datetime "expires_at"
    t.boolean "deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", null: false
    t.string "digest", null: false
    t.string "name", default: "", null: false
    t.string "ip", default: "", null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sessions_on_account_id"
    t.index ["uuid"], name: "index_sessions_on_uuid", unique: true
  end

  add_foreign_key "captures", "accounts", column: "receiver_id"
  add_foreign_key "captures", "accounts", column: "sender_id"
  add_foreign_key "captures", "groups"
  add_foreign_key "comments", "accounts"
  add_foreign_key "comments", "captures"
  add_foreign_key "entries", "accounts"
  add_foreign_key "entries", "groups"
  add_foreign_key "follows", "accounts", column: "followed_id"
  add_foreign_key "follows", "accounts", column: "follower_id"
  add_foreign_key "groups", "accounts"
  add_foreign_key "images", "accounts"
  add_foreign_key "sessions", "accounts"
end
