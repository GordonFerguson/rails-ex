# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180218160439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "adminpack"

  create_table "articles", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "boris_users", id: :integer, default: -> { "nextval('users_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "login_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "role", limit: 40, default: "guest"
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.integer "approved", limit: 2, default: 0, null: false
    t.index ["email"], name: "public_users_email1_idx", unique: true
    t.index ["reset_password_token"], name: "public_users_reset_password_token2_idx", unique: true
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "commenter"
    t.text "body"
    t.integer "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_comments_on_article_id"
  end

  create_table "credits", id: :serial, force: :cascade do |t|
    t.integer "production_id"
    t.integer "person_id"
    t.string "credit_code", limit: 3
    t.integer "credit_seq", limit: 2
    t.string "note", limit: 255
    t.string "name", limit: 255
    t.string "role", limit: 255
    t.string "credit", limit: 255
    t.integer "position"
    t.integer "team_id"
    t.string "team_type", limit: 255
    t.string "category", limit: 255
    t.index ["person_id"], name: "public_credits_person_id1_idx"
    t.index ["production_id"], name: "public_credits_production_id2_idx"
    t.index ["team_type", "team_id"], name: "public_credits_team_type3_idx"
  end

  create_table "designers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 61
    t.string "name_with_markup", limit: 50
    t.text "bio"
    t.text "working_notes"
    t.datetime "updated_at"
    t.datetime "proofed_on"
    t.datetime "change_date"
    t.integer "is_attn_required", limit: 2
    t.integer "is_high_priority", limit: 2
    t.string "designer_number", limit: 255
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "name", limit: 61
    t.string "name_with_markup", limit: 50
    t.text "bio"
    t.text "working_notes"
    t.datetime "updated_at"
    t.datetime "proofed_on"
    t.datetime "change_date"
    t.integer "is_attn_required", limit: 2
    t.integer "is_high_priority", limit: 2
    t.string "designer_number", limit: 255
  end

  create_table "productions", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.date "opened_on"
    t.string "note", limit: 255
    t.date "closed_on"
    t.string "theater", limit: 255
    t.string "author", limit: 255
    t.text "sponsors"
    t.string "status", limit: 255
    t.string "entered_by", limit: 255
    t.string "reviewed_by", limit: 255
    t.string "temp_year", limit: 255
    t.integer "season_id"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "source_notes"
    t.index ["season_id"], name: "public_productions_season_id3_idx"
    t.index ["title"], name: "public_productions_title1_idx"
    t.index ["title"], name: "public_productions_title2_idx"
  end

  create_table "seasons", id: :serial, force: :cascade do |t|
    t.string "year", limit: 255
    t.string "year2", limit: 255
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", limit: 255
  end

  create_table "users", id: :bigint, default: -> { "nextval('users_id_seq1'::regclass)" }, force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.string "hashed_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  add_foreign_key "comments", "articles"
end
