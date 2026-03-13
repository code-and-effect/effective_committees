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

ActiveRecord::Schema[8.1].define(version: 101) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "committee_files", force: :cascade do |t|
    t.integer "committee_folder_id"
    t.integer "committee_id"
    t.string "committee_type"
    t.datetime "created_at", precision: nil
    t.datetime "file_created_at", precision: nil
    t.integer "file_id"
    t.text "notes"
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["committee_id"], name: "index_committee_files_on_committee_id"
    t.index ["title"], name: "index_committee_files_on_title"
  end

  create_table "committee_folders", force: :cascade do |t|
    t.integer "committee_files_count", default: 0
    t.string "committee_folder_id"
    t.integer "committee_id"
    t.string "committee_type"
    t.datetime "created_at", precision: nil
    t.integer "position"
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["committee_id", "committee_type"], name: "index_committee_folders_on_committee_id_and_committee_type"
    t.index ["committee_id"], name: "index_committee_folders_on_committee_id"
    t.index ["position"], name: "index_committee_folders_on_position"
  end

  create_table "committee_members", force: :cascade do |t|
    t.string "category"
    t.integer "committee_id"
    t.string "committee_type"
    t.datetime "created_at", precision: nil
    t.date "end_on"
    t.integer "position"
    t.integer "roles_mask"
    t.date "start_on"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.string "user_type"
    t.index ["committee_id"], name: "index_committee_members_on_committee_id"
    t.index ["user_id", "user_type"], name: "index_committee_members_on_user_id_and_user_type"
    t.index ["user_id"], name: "index_committee_members_on_user_id"
  end

  create_table "committees", force: :cascade do |t|
    t.integer "committee_files_count", default: 0
    t.integer "committee_folders_count", default: 0
    t.integer "committee_members_count", default: 0
    t.datetime "created_at", precision: nil
    t.boolean "display_on_dashboard", default: true
    t.boolean "display_on_index", default: true
    t.integer "position"
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["slug"], name: "index_committees_on_slug"
    t.index ["title"], name: "index_committees_on_title"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "roles_mask"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
