class GeneratedPlaylist < ApplicationRecord
  belongs_to :user
  has_many :playlist_tracks, dependent: :destroy
end