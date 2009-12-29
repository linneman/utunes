# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090228194831) do

  create_table "audio_sources", :force => true do |t|
    t.integer  "bundle_source_id"
    t.integer  "file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bundle_comments", :force => true do |t|
    t.integer  "bundle_id"
    t.integer  "user_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bundle_sources", :force => true do |t|
    t.integer  "bundle_id"
    t.integer  "user_id"
    t.boolean  "ENU"
    t.boolean  "SPM"
    t.boolean  "FRC"
    t.boolean  "GED"
    t.boolean  "ENG"
    t.boolean  "FRF"
    t.boolean  "ITI"
    t.boolean  "SPE"
    t.boolean  "DUN"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
  end

  create_table "bundles", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.decimal  "price",              :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency_code",                                    :default => "EUR"
    t.boolean  "ENU",                                              :default => true
    t.boolean  "SPM",                                              :default => false
    t.boolean  "FRC",                                              :default => false
    t.boolean  "GED",                                              :default => false
    t.boolean  "ENG",                                              :default => true
    t.boolean  "FRF",                                              :default => false
    t.boolean  "ITI",                                              :default => false
    t.boolean  "SPE",                                              :default => false
    t.boolean  "DUN",                                              :default => false
    t.integer  "created_by_user_id"
    t.integer  "level",                                            :default => 0
    t.boolean  "public",                                           :default => false
  end

  create_table "hc12_sources", :force => true do |t|
    t.integer  "bundle_id"
    t.integer  "user_id"
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",      :default => 1
  end

  create_table "order_items", :force => true do |t|
    t.integer  "bundle_id"
    t.integer  "user_id"
    t.integer  "price",               :limit => 10, :precision => 10, :scale => 0
    t.datetime "placed_at",                                                        :default => '2009-12-28 15:20:44'
    t.datetime "payment_received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "currency_code"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "translations", :force => true do |t|
    t.string   "enu"
    t.string   "frc"
    t.string   "spm"
    t.string   "ged"
    t.string   "dun"
    t.string   "eng"
    t.string   "frf"
    t.string   "spe"
    t.string   "iti"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "email"
    t.binary   "ecudata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed",         :default => false
    t.string   "confirmation_link"
    t.string   "content_type"
    t.integer  "level",             :default => 0
  end

end
