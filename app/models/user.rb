class User < ApplicationRecord
  has_many :generated_playlists, dependent: :destroy
  has_many :tracks, dependent: :destroy
end