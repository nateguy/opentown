# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140831020306) do

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.boolean  "like"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.string   "district"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "content"
  end

  create_table "polygons", force: true do |t|
    t.integer  "plan_id"
    t.string   "polygontype"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "zone_id"
    t.string   "description"
  end

  create_table "user_polygons", force: true do |t|
    t.integer "user_id"
    t.integer "polygon_id"
    t.integer "custom_zone"
    t.string  "custom_description"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "vertices", force: true do |t|
    t.integer  "polygon_id"
    t.float    "lat"
    t.float    "lng"
    t.boolean  "todelete"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", force: true do |t|
    t.string   "code"
    t.string   "description"
    t.string   "classification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color_code"
    t.string   "texture_file_name"
    t.string   "texture_content_type"
    t.integer  "texture_file_size"
    t.datetime "texture_updated_at"
  end

end
