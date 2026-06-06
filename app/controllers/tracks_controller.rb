class TracksController < ApplicationController
  include SpotifyAuthenticable

  def liked
    tracks = spotify_client.all_liked_tracks
    render json: { total: tracks.size, tracks: tracks }
  end
end