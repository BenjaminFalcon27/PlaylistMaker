class TracksController < ApplicationController
  include SpotifyAuthenticable

  def sync
    SyncTracksJob.perform_later(current_user.id)
    render json: { status: 'queued' }
  end

  def liked
    render json: { total: current_user.tracks.count, tracks: current_user.tracks }
  end
end