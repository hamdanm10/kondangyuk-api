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

ActiveRecord::Schema[8.1].define(version: 2026_06_26_141506) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "order_status", ["pending", "working", "review", "completed"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "invitation_documents", force: :cascade do |t|
    t.text "document", null: false
    t.bigint "invitation_id", null: false
    t.jsonb "meta", default: {}, null: false
    t.index ["invitation_id"], name: "index_invitation_documents_on_invitation_id", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.datetime "expires_at", precision: nil
    t.string "name", null: false
    t.bigint "order_id", null: false
    t.datetime "published_at", precision: nil
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_invitations_on_order_id"
    t.index ["slug"], name: "index_invitations_on_slug", unique: true
  end

  create_table "marketplaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.bigint "marketplace_id", null: false
    t.string "order_number", null: false
    t.enum "status", default: "pending", null: false, enum_type: "order_status"
    t.bigint "template_id", null: false
    t.datetime "updated_at", null: false
    t.index ["marketplace_id", "order_number"], name: "index_orders_on_marketplace_id_and_order_number", unique: true, where: "(deleted_at IS NULL)"
    t.index ["template_id"], name: "index_orders_on_template_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil
    t.string "ip_address"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "template_documents", force: :cascade do |t|
    t.text "document", null: false
    t.jsonb "meta", default: {}, null: false
    t.bigint "template_id", null: false
    t.index ["template_id"], name: "index_template_documents_on_template_id", unique: true
  end

  create_table "template_themes", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.bigint "theme_id", null: false
    t.index ["template_id", "theme_id"], name: "index_template_themes_on_template_id_and_theme_id", unique: true
    t.index ["template_id"], name: "index_template_themes_on_template_id"
    t.index ["theme_id"], name: "index_template_themes_on_theme_id"
  end

  create_table "template_tiers", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.bigint "tier_id", null: false
    t.index ["template_id"], name: "index_template_tiers_on_template_id", unique: true
    t.index ["tier_id"], name: "index_template_tiers_on_tier_id"
  end

  create_table "templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id", null: false
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.string "name", null: false
    t.datetime "published_at", precision: nil
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_templates_on_created_by_user_id"
    t.index ["slug"], name: "index_templates_on_slug", unique: true
  end

  create_table "themes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tiers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.string "name", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.boolean "is_active", default: true, null: false
    t.string "password_digest", null: false
    t.string "role", default: "admin", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "invitation_documents", "invitations"
  add_foreign_key "invitations", "orders"
  add_foreign_key "orders", "marketplaces"
  add_foreign_key "orders", "templates"
  add_foreign_key "sessions", "users"
  add_foreign_key "template_documents", "templates"
  add_foreign_key "template_themes", "templates"
  add_foreign_key "template_themes", "themes"
  add_foreign_key "template_tiers", "templates"
  add_foreign_key "template_tiers", "tiers"
  add_foreign_key "templates", "users", column: "created_by_user_id"
end
