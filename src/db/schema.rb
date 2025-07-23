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
    t.string "anyur_id"
    t.string "anyur_access_token", default: "", null: false
    t.string "anyur_refresh_token", default: "", null: false
    t.string "aid", limit: 14, null: false
    t.string "name", null: false
    t.string "name_id", null: false
    t.text "description", default: "", null: false
    t.datetime "birth"
    t.string "email", default: "", null: false
    t.boolean "email_verified", default: false, null: false
    t.string "roles", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "icon_id"
    t.index ["aid"], name: "index_accounts_on_aid", unique: true
    t.index ["anyur_id"], name: "index_accounts_on_anyur_id", unique: true
    t.index ["icon_id"], name: "fk_rails_fc2285bd47"
    t.index ["name_id"], name: "index_accounts_on_name_id", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "activity_logs", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "aid", limit: 14, null: false
    t.bigint "account_id"
    t.string "loggable_type"
    t.bigint "loggable_id"
    t.string "action_name", default: "", null: false
    t.text "attribute_data", size: :long, default: "[]", null: false, collation: "utf8mb4_bin"
    t.datetime "changed_at", default: -> { "current_timestamp(6)" }, null: false
    t.string "change_reason", default: "", null: false
    t.string "user_agent", default: "", null: false
    t.string "ip_address", default: "", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_activity_logs_on_account_id"
    t.index ["aid"], name: "index_activity_logs_on_aid", unique: true
    t.index ["loggable_type", "loggable_id"], name: "index_activity_logs_on_loggable"
    t.check_constraint "json_valid(`attribute_data`)", name: "attribute_data"
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "captures", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "aid", limit: 14, null: false
    t.bigint "sender_id", null: false
    t.bigint "receiver_id"
    t.bigint "sender_capture_id"
    t.bigint "group_id"
    t.string "front_original_key", default: "", null: false
    t.string "front_variants", default: "", null: false
    t.string "back_original_key", default: "", null: false
    t.string "back_variants", default: "", null: false
    t.boolean "reversed", default: false, null: false
    t.decimal "latitude", precision: 10
    t.decimal "longitude", precision: 10
    t.string "comment", default: "", null: false
    t.datetime "captured_at"
    t.integer "visibility", limit: 1, default: 0, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aid"], name: "index_captures_on_aid", unique: true
    t.index ["group_id"], name: "index_captures_on_group_id"
    t.index ["receiver_id"], name: "fk_rails_436bbf3df3"
    t.index ["sender_capture_id"], name: "fk_rails_77f92f8bd1"
    t.index ["sender_id"], name: "fk_rails_ce2cf603f1"
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "capture_id", null: false
    t.string "aid", null: false
    t.string "content", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
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
    t.index ["follower_id"], name: "fk_rails_622d34a301"
  end

  create_table "groups", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "aid", null: false
    t.string "name", default: "", null: false
    t.text "description", default: "", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "icon_id"
    t.index ["account_id"], name: "index_groups_on_account_id"
    t.index ["aid"], name: "index_groups_on_aid", unique: true
    t.index ["icon_id"], name: "fk_rails_79bcbd1e53"
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "images", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.string "aid", null: false
    t.string "name", default: "", null: false
    t.string "original_key", default: "", null: false
    t.string "variants", default: "", null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_images_on_account_id"
    t.index ["aid"], name: "index_images_on_aid", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "aid", limit: 14, null: false
    t.bigint "account_id", null: false
    t.string "name", default: "", null: false
    t.string "token_lookup", null: false
    t.string "token_digest", null: false
    t.datetime "token_expires_at", default: -> { "current_timestamp(6)" }, null: false
    t.datetime "token_generated_at", default: -> { "current_timestamp(6)" }, null: false
    t.text "meta", size: :long, default: "{}", null: false, collation: "utf8mb4_bin"
    t.integer "status", limit: 1, default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sessions_on_account_id"
    t.index ["aid"], name: "index_sessions_on_aid", unique: true
    t.index ["token_lookup"], name: "index_sessions_on_token_lookup", unique: true
    t.check_constraint "json_valid(`meta`)", name: "meta"
  end

  add_foreign_key "accounts", "images", column: "icon_id"
  add_foreign_key "activity_logs", "accounts"
  add_foreign_key "captures", "accounts", column: "receiver_id"
  add_foreign_key "captures", "accounts", column: "sender_id"
  add_foreign_key "captures", "captures", column: "sender_capture_id"
  add_foreign_key "captures", "groups"
  add_foreign_key "comments", "accounts"
  add_foreign_key "comments", "captures"
  add_foreign_key "entries", "accounts"
  add_foreign_key "entries", "groups"
  add_foreign_key "follows", "accounts", column: "followed_id"
  add_foreign_key "follows", "accounts", column: "follower_id"
  add_foreign_key "groups", "accounts"
  add_foreign_key "groups", "images", column: "icon_id"
  add_foreign_key "images", "accounts"
  add_foreign_key "sessions", "accounts"
end
