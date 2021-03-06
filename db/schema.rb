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

ActiveRecord::Schema.define(version: 20140915181453) do

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

  create_table "plan_statuses", force: true do |t|
    t.integer  "plan_id"
    t.integer  "status_id"
    t.integer  "stage"
    t.datetime "effect_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.string   "district"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content"
    t.string   "overlay_file_name"
    t.string   "overlay_content_type"
    t.integer  "overlay_file_size"
    t.datetime "overlay_updated_at"
    t.float    "sw_lat"
    t.float    "sw_lng"
    t.float    "ne_lat"
    t.float    "ne_lng"
  end

  create_table "polygons", force: true do |t|
    t.integer  "plan_id"
    t.integer  "zone_id"
    t.string   "polygontype"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "ratings", force: true do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "nickname"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "location"
    t.boolean  "admin"
    t.boolean  "need_admin_approval"
    t.boolean  "super_admin"
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
