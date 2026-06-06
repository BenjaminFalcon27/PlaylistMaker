class CreateTracks < ActiveRecord::Migration[8.1]
  def change
    create_table :tracks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :spotify_id
      t.string :title
      t.string :artist_name
      t.string :artist_id
      t.string :album_name
      t.datetime :added_at
      t.integer :duration_ms
      t.integer :popularity
      t.string :release_date
      t.string :preview_url
      t.jsonb :genres
      t.jsonb :audio_features

      t.timestamps
    end
    add_index :tracks, :spotify_id, unique: true
  end
end
