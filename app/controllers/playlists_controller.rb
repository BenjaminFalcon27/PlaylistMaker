class PlaylistsController < ApplicationController
  include SpotifyAuthenticable

  def generate
    categories = params[:categories] || []
    groups = Classifier::ByGenre.new(current_user).call
    spotify_user_id = spotify_client.me['id']

    categories.each do |category|
      tracks = groups[category]
      next unless tracks&.any?

      playlist = spotify_client.create_playlist(spotify_user_id, category.capitalize)
      spotify_playlist_id = playlist['id']

      track_uris = tracks.map { |t| "spotify:track:#{t.spotify_id}" }
      spotify_client.add_tracks_to_playlist(spotify_playlist_id, track_uris)

      generated = GeneratedPlaylist.create!(
        user: current_user,
        spotify_playlist_id: spotify_playlist_id,
        name: category,
        classifier: 'by_genre'
      )

      records = tracks.map do |t|
        { generated_playlist_id: generated.id, spotify_track_id: t.spotify_id, created_at: Time.now, updated_at: Time.now }
      end
      PlaylistTrack.insert_all(records)
    end

    render json: { status: 'generated', categories: categories }
  end
end
