# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_24_103525) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ahoy_events", id: :serial, force: :cascade do |t|
    t.integer "visit_id"
    t.integer "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties_jsonb_path_ops", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", id: :serial, force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.integer "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "availabilities", id: :serial, force: :cascade do |t|
    t.integer "week_day"
    t.integer "profile_id"
    t.string "timing"
    t.boolean "full_day_off", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "start_time"
    t.time "end_time"
    t.index ["profile_id"], name: "index_availabilities_on_profile_id"
  end

  create_table "bookings", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "start"
    t.datetime "end"
    t.string "duration"
    t.datetime "cancel_date"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "guide_id"
    t.integer "explore_id"
    t.string "identifier"
    t.string "slug"
    t.string "description"
    t.integer "client_id"
    t.integer "recipient_id"
    t.integer "coins"
    t.boolean "flag", default: false
    t.index ["explore_id"], name: "index_bookings_on_explore_id"
    t.index ["guide_id"], name: "index_bookings_on_guide_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "description"
    t.boolean "verified", default: false
  end

  create_table "categories_projects", id: false, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "project_id", null: false
  end

  create_table "chats", id: :serial, force: :cascade do |t|
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "subject"
    t.string "message"
    t.string "linkedin_url"
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "explore_ratings", id: :serial, force: :cascade do |t|
    t.string "review"
    t.float "rating"
    t.integer "profile_id"
    t.integer "guide_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "explore_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_explore_ratings_on_category_id"
    t.index ["explore_id"], name: "index_explore_ratings_on_explore_id"
    t.index ["guide_id"], name: "index_explore_ratings_on_guide_id"
    t.index ["profile_id"], name: "index_explore_ratings_on_profile_id"
  end

  create_table "explores", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profile_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_explores_on_category_id"
    t.index ["profile_id"], name: "index_explores_on_profile_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "guide_ratings", id: :serial, force: :cascade do |t|
    t.string "review"
    t.float "rating"
    t.integer "profile_id"
    t.integer "explore_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "guide_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_guide_ratings_on_category_id"
    t.index ["explore_id"], name: "index_guide_ratings_on_explore_id"
    t.index ["guide_id"], name: "index_guide_ratings_on_guide_id"
    t.index ["profile_id"], name: "index_guide_ratings_on_profile_id"
  end

  create_table "guides", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profile_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_guides_on_category_id"
    t.index ["profile_id"], name: "index_guides_on_profile_id"
  end

  create_table "helps", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "markets", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "currency"
    t.string "mode"
    t.string "interval"
    t.integer "price"
    t.string "offer"
    t.string "description"
    t.string "stripe_id"
    t.integer "coins"
    t.integer "order"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content"
    t.integer "user_id"
    t.integer "chat_id"
    t.datetime "read_at"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.string "action"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.string "url"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "personal_settings", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.boolean "new_message", default: false
    t.boolean "after_booking", default: true
    t.boolean "change_request", default: true
    t.boolean "booking_decline", default: true
    t.boolean "coins_purchased", default: true
    t.boolean "change_session_details", default: true
    t.boolean "booking_pending", default: false
    t.boolean "change_request_accepted", default: true
    t.boolean "hour_reminder", default: true
    t.boolean "new_rating", default: false
    t.boolean "news_letter", default: false
    t.boolean "suggestion", default: false
    t.integer "schedule_time"
    t.integer "buffer_time"
    t.index ["profile_id"], name: "index_personal_settings_on_profile_id"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "state"
    t.string "country"
    t.string "profile_photo"
    t.string "banner_photo"
    t.string "languages"
    t.string "bio"
    t.string "contact_no"
    t.date "birth_date"
    t.string "city"
    t.string "slug"
    t.string "time_zone"
    t.float "latitude"
    t.float "longitude"
    t.string "blocked_users"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "project_comments", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "profile_id"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_project_comments_on_profile_id"
    t.index ["project_id"], name: "index_project_comments_on_project_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "status"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profile_id"
    t.string "colab_id"
    t.boolean "help"
    t.text "summary"
    t.text "gaps"
    t.text "challenges"
    t.string "tools"
    t.string "supplies"
    t.date "completion_date"
    t.string "help_needed"
    t.index ["profile_id"], name: "index_projects_on_profile_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.string "reported_type"
    t.integer "reported_id"
    t.boolean "spam", default: false
    t.boolean "mature", default: false
    t.boolean "abusive", default: false
    t.boolean "self_harm", default: false
    t.boolean "copyright", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_reports_on_profile_id"
    t.index ["reported_type", "reported_id"], name: "index_reports_on_reported_type_and_reported_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "subscribes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "chat_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.string "name"
    t.string "currency"
    t.string "mode"
    t.string "interval"
    t.integer "price"
    t.string "customer_id"
    t.string "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "charge_id"
    t.integer "market_id"
    t.index ["market_id"], name: "index_transactions_on_market_id"
    t.index ["profile_id"], name: "index_transactions_on_profile_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firstname"
    t.string "lastname"
    t.string "provider", limit: 50, default: "", null: false
    t.string "uid", limit: 500, default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.boolean "builder", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "video_sessions", id: :serial, force: :cascade do |t|
    t.integer "booking_id"
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallet_histories", id: :serial, force: :cascade do |t|
    t.integer "wallet_id"
    t.integer "cost"
    t.integer "prev_bal"
    t.integer "new_bal"
    t.string "action_type"
    t.integer "action_id"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type", "action_id"], name: "index_wallet_histories_on_action_type_and_action_id"
    t.index ["wallet_id"], name: "index_wallet_histories_on_wallet_id"
  end

  create_table "wallets", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "coins"
    t.index ["profile_id"], name: "index_wallets_on_profile_id"
  end

  add_foreign_key "availabilities", "profiles"
  add_foreign_key "bookings", "explores", on_delete: :nullify
  add_foreign_key "bookings", "guides", on_delete: :nullify
  add_foreign_key "explore_ratings", "categories"
  add_foreign_key "explore_ratings", "explores", on_delete: :cascade
  add_foreign_key "explore_ratings", "guides", on_delete: :cascade
  add_foreign_key "explore_ratings", "profiles"
  add_foreign_key "explores", "categories", on_delete: :cascade
  add_foreign_key "explores", "profiles"
  add_foreign_key "guide_ratings", "categories"
  add_foreign_key "guide_ratings", "explores", on_delete: :cascade
  add_foreign_key "guide_ratings", "guides", on_delete: :cascade
  add_foreign_key "guide_ratings", "profiles"
  add_foreign_key "guides", "categories", on_delete: :cascade
  add_foreign_key "guides", "profiles"
  add_foreign_key "notifications", "users"
  add_foreign_key "personal_settings", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "project_comments", "profiles"
  add_foreign_key "project_comments", "projects"
  add_foreign_key "projects", "profiles"
  add_foreign_key "reports", "profiles"
  add_foreign_key "transactions", "markets"
  add_foreign_key "transactions", "profiles"
  add_foreign_key "wallet_histories", "wallets"
  add_foreign_key "wallets", "profiles"
end
