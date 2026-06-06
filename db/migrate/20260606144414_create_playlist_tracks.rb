class CreatePlaylistTracks < ActiveRecord::Migration[8.1]
  def change
    create_table :playlist_tracks do |t|
      t.references :generated_playlist, null: false, foreign_key: true
      t.string :spotify_track_id
      t.string :title
      t.string :artist
      t.string :album
      t.string :genres
      t.jsonb :audio_features

      t.timestamps
    end
  end
end
