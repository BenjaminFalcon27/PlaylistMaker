class CreateGeneratedPlaylists < ActiveRecord::Migration[8.1]
  def change
    create_table :generated_playlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :spotify_playlist_id
      t.string :name
      t.string :classifier
      t.integer :tracks_count

      t.timestamps
    end
  end
end
