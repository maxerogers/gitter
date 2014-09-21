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

ActiveRecord::Schema.define(version: 20140921124038) do

  create_table "languages", force: true do |t|
    t.string  "name"
    t.integer "number_of_files"
    t.integer "number_of_lines"
    t.string  "file_extensions"
    t.integer "hourly_count"
  end

  create_table "repos", force: true do |t|
    t.string  "github_path"
    t.string  "last_sha"
    t.integer "lines"
  end

  create_table "users", force: true do |t|
    t.string  "name"
    t.integer "twitter_id"
    t.string  "github_path"
    t.string  "twitter_token"
    t.string  "twitter_secret"
    t.integer "team_id"
  end

end
