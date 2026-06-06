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

ActiveRecord::Schema[8.1].define(version: 2026_06_06_152042) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "generated_playlists", force: :cascade do |t|
    t.string "classifier"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "spotify_playlist_id"
    t.integer "tracks_count"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_generated_playlists_on_user_id"
  end

  create_table "playlist_tracks", force: :cascade do |t|
    t.string "album"
    t.string "artist"
    t.jsonb "audio_features"
    t.datetime "created_at", null: false
    t.bigint "generated_playlist_id", null: false
    t.string "genres"
    t.string "spotify_track_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["generated_playlist_id"], name: "index_playlist_tracks_on_generated_playlist_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.datetime "added_at"
    t.string "album_name"
    t.string "artist_id"
    t.string "artist_name"
    t.jsonb "audio_features"
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.jsonb "genres"
    t.integer "popularity"
    t.string "preview_url"
    t.string "release_date"
    t.string "spotify_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["spotify_id"], name: "index_tracks_on_spotify_id", unique: true
    t.index ["user_id"], name: "index_tracks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email"
    t.datetime "last_synced_at"
    t.string "spotify_refresh_token"
    t.string "spotify_token"
    t.string "spotify_uid"
    t.datetime "token_expires_at"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "generated_playlists", "users"
  add_foreign_key "playlist_tracks", "generated_playlists"
  add_foreign_key "tracks", "users"
end
