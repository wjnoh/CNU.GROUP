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

ActiveRecord::Schema.define(version: 20170913071425) do

  create_table "accept_applies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_accept_applies_on_board_id"
    t.index ["user_id"], name: "index_accept_applies_on_user_id"
  end

  create_table "adposts", force: :cascade do |t|
    t.integer "user_id"
    t.string "writer"
    t.string "title"
    t.string "content"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_adposts_on_user_id"
  end

  create_table "applies", force: :cascade do |t|
    t.integer "board_id"
    t.integer "user_id"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_applies_on_board_id"
    t.index ["user_id"], name: "index_applies_on_user_id"
  end

  create_table "boards", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "info"
    t.string "category"
    t.integer "memberCount"
    t.integer "totalNumberOfMember"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_boards_on_user_id"
  end

  create_table "class_rooms", force: :cascade do |t|
    t.integer "college_id"
    t.string "classRoomName"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["college_id"], name: "index_class_rooms_on_college_id"
  end

  create_table "class_times", force: :cascade do |t|
    t.integer "classRoom_id"
    t.string "dayAndTimeInterval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classRoom_id"], name: "index_class_times_on_classRoom_id"
  end

  create_table "colleges", force: :cascade do |t|
    t.string "collegeName"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "day_and_time_of_classes", force: :cascade do |t|
    t.integer "classTime_id"
    t.string "day"
    t.string "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classTime_id"], name: "index_day_and_time_of_classes_on_classTime_id"
  end

  create_table "freeposts", force: :cascade do |t|
    t.integer "user_id"
    t.string "writer"
    t.string "title"
    t.string "content"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_freeposts_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "alt"
    t.string "hint"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notices", force: :cascade do |t|
    t.integer "user_id"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notices_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "board_id"
    t.string "modifyFileName"
    t.string "originalFileName"
    t.string "writer"
    t.string "title"
    t.text "content"
    t.boolean "notice", default: false
    t.boolean "info", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_posts_on_board_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "post_id"
    t.integer "freepost_id"
    t.integer "adpost_id"
    t.integer "suggestionpost_id"
    t.string "replyWriter"
    t.text "replyContent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adpost_id"], name: "index_replies_on_adpost_id"
    t.index ["freepost_id"], name: "index_replies_on_freepost_id"
    t.index ["post_id"], name: "index_replies_on_post_id"
    t.index ["suggestionpost_id"], name: "index_replies_on_suggestionpost_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "suggestionposts", force: :cascade do |t|
    t.integer "user_id"
    t.string "writer"
    t.string "title"
    t.string "content"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_suggestionposts_on_user_id"
  end

  create_table "timetables", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.boolean "main", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_timetables_on_user_id"
  end

  create_table "ttcells", force: :cascade do |t|
    t.integer "timetable_id"
    t.string "cellId"
    t.string "cellName"
    t.integer "rowSpan"
    t.integer "colSpan"
    t.string "cellColor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "acceptApply_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.integer "studentid", null: false
    t.string "profile_picture", default: "http://pds26.egloos.com/pds/201712/23/70/c0116970_5a3dfee5b05bb.png", null: false
    t.integer "board_count", default: 0
    t.string "gender", default: "남", null: false
    t.boolean "receiveNotice", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acceptApply_id"], name: "index_users_on_acceptApply_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
