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

ActiveRecord::Schema.define(version: 20151217161708) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "ain_shapes", force: :cascade do |t|
    t.geometry "shape", limit: {:srid=>0, :type=>"polygon"}
    t.string   "ain"
  end

  create_table "ain_shapes_master_records", force: :cascade do |t|
    t.integer "master_record_id"
    t.integer "ain_shape_id"
    t.string  "match_method"
  end

  create_table "master_records", force: :cascade do |t|
    t.string "file_name"
    t.string "apn_given"
    t.string "address_given"
    t.string "address_from_apn"
    t.float  "address_latitude"
    t.float  "address_longitude"
  end

end
