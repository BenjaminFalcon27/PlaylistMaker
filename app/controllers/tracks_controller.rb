class TracksController < ApplicationController
  include SpotifyAuthenticable

  def full_sync
    FullSyncTracksJob.perform_later(current_user.id)
    render json: { status: 'queued' }
  end

  def sync
    SyncTracksJob.perform_later(current_user.id)
    render json: { status: 'queued' }
  end

  def fetch_genres
    FetchGenresJob.perform_later(current_user.id)
    render json: { status: 'queued' }
  end

  def genres_status
    tracks = current_user.tracks
    render json: {
      total: tracks.count,
      with_genres: tracks.where.not(genres: nil).count,
      without_genres: tracks.where(genres: nil).count
    }
  end

  def liked
    render json: { total: current_user.tracks.count, tracks: current_user.tracks }
  end
end