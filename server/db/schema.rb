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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140316004229) do

  create_table "badbehaviors", :force => true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.string   "reminders"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.date     "date"
  end

  create_table "changebehaviors", :force => true do |t|
    t.integer  "client_id"
    t.string   "badbh_id"
    t.integer  "badbh_user_id"
    t.string   "badbh_device_id"
    t.string   "bhname"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.date     "date"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
  end

  create_table "deleted_badbehaviors", :force => true do |t|
    t.integer  "badbehaviors_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "deleted_changebehaviors", :force => true do |t|
    t.integer  "changebehaviors_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "deleted_goodbehaviors", :force => true do |t|
    t.integer  "goodbehaviors_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "deleted_notebooks", :force => true do |t|
    t.text     "device_id"
    t.integer  "user_id"
    t.string   "notebook_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "deleted_rewards", :force => true do |t|
    t.integer  "reward_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "deleted_rewardtimes", :force => true do |t|
    t.integer  "rewardtime_id"
    t.integer  "user_id"
    t.string   "client_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "device_id"
  end

  create_table "deleted_savedrewards", :force => true do |t|
    t.integer  "savedreward_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "deleted_tokenhistories", :force => true do |t|
    t.integer  "tokenhistory_id"
    t.integer  "user_id"
    t.string   "client_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "device_id"
  end

  create_table "deleted_trackchangebehaviors", :force => true do |t|
    t.integer  "trackchangebehaviors_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "deleted_trackgoodbehaviors", :force => true do |t|
    t.integer  "trackgoodbehaviors_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "devices", :force => true do |t|
    t.integer  "user_id"
    t.string   "device"
    t.datetime "last_sync"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "current_sync"
  end

  create_table "goodbehaviors", :force => true do |t|
    t.integer  "client_id"
    t.string   "bhname"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.date     "date"
  end

  create_table "notebooks", :force => true do |t|
    t.integer  "user_id"
    t.string   "book_status"
    t.string   "book_name"
    t.datetime "age"
    t.integer  "tokens"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "device_id"
    t.integer  "client_id"
    t.text     "picture"
    t.datetime "picture_updated"
  end

  create_table "rewards", :force => true do |t|
    t.integer  "client_id"
    t.string   "reward_name"
    t.integer  "price"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "rewardtimes", :force => true do |t|
    t.integer  "client_id"
    t.string   "timeperiod"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "savedrewards", :force => true do |t|
    t.integer  "client_id"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "rewards_id"
    t.integer  "rewards_user_id"
    t.string   "rewards_client_id"
    t.string   "rewards_status"
    t.date     "date"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "reward_name"
  end

  create_table "tokenhistories", :force => true do |t|
    t.integer  "client_id"
    t.date     "date"
    t.integer  "begin_token"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "trackchangebehaviors", :force => true do |t|
    t.integer  "client_id"
    t.date     "time_record"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "changebehaviors_id"
    t.integer  "changebehaviors_user_id"
    t.string   "changebehaviors_device_id"
    t.string   "time1"
    t.string   "time2"
    t.string   "time3"
    t.string   "time4"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "trackgoodbehaviors", :force => true do |t|
    t.integer  "client_id"
    t.date     "time_record"
    t.integer  "notebooks_id"
    t.integer  "notebooks_user_id"
    t.string   "notebooks_device_id"
    t.integer  "goodbehaviors_id"
    t.integer  "goodbehaviors_user_id"
    t.string   "goodbehaviors_device_id"
    t.string   "time1"
    t.string   "time2"
    t.string   "time3"
    t.string   "time4"
    t.integer  "user_id"
    t.string   "device_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
