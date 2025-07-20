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

ActiveRecord::Schema[8.0].define(version: 2025_07_20_081624) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chords", force: :cascade do |t|
    t.bigint "measure_id", null: false
    t.integer "position", null: false
    t.integer "root_offset", null: false
    t.integer "bass_offset", null: false
    t.string "type", default: "0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["measure_id"], name: "index_chords_on_measure_id"
  end

  create_table "measures", force: :cascade do |t|
    t.bigint "score_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["score_id"], name: "index_measures_on_score_id"
  end

  create_table "scores", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "user_id", null: false
    t.boolean "published", default: false
    t.integer "tempo", null: false
    t.integer "key", null: false, comment: "0: A, 1: A#, 2: B, 3: C, 4: C#, 5: D, 6: D#, 7: E, 8: F, 9: F#, 10: G, 11: G#"
    t.string "time_signature", null: false
    t.text "lyrics"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key_name", null: false, comment: "distinguishing A# from Bb"
    t.index ["user_id"], name: "index_scores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id", unique: true
  end

  add_foreign_key "chords", "measures"
  add_foreign_key "measures", "scores"
  add_foreign_key "scores", "users"
end
