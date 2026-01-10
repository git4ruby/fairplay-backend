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

ActiveRecord::Schema[8.0].define(version: 2026_01_10_211959) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "club_ownerships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_club_ownerships_on_club_id"
    t.index ["user_id", "club_id"], name: "index_club_ownerships_on_user_id_and_club_id", unique: true
    t.index ["user_id"], name: "index_club_ownerships_on_user_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "name", null: false
    t.text "address", null: false
    t.integer "no_of_courts", default: 1, null: false
    t.string "email"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_clubs_on_name"
  end

  create_table "courts", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id", "name"], name: "index_courts_on_club_id_and_name", unique: true
    t.index ["club_id"], name: "index_courts_on_club_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "match_players", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "user_id", null: false
    t.integer "team_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id", "user_id"], name: "index_match_players_on_match_id_and_user_id", unique: true
    t.index ["match_id"], name: "index_match_players_on_match_id"
    t.index ["user_id"], name: "index_match_players_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "court_id", null: false
    t.integer "match_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_matches_on_court_id"
    t.index ["start_time"], name: "index_matches_on_start_time"
    t.index ["status"], name: "index_matches_on_status"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "user_id", null: false
    t.string "video_url", null: false
    t.string "landing_frame_url"
    t.integer "decision"
    t.decimal "confidence", precision: 5, scale: 2
    t.decimal "landing_x", precision: 10, scale: 6
    t.decimal "landing_y", precision: 10, scale: 6
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_reviews_on_created_at"
    t.index ["match_id"], name: "index_reviews_on_match_id"
    t.index ["status"], name: "index_reviews_on_status"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "club_ownerships", "clubs"
  add_foreign_key "club_ownerships", "users"
  add_foreign_key "courts", "clubs"
  add_foreign_key "match_players", "matches"
  add_foreign_key "match_players", "users"
  add_foreign_key "matches", "courts"
  add_foreign_key "reviews", "matches"
  add_foreign_key "reviews", "users"
end
