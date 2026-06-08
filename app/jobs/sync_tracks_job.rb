class SyncTracksJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    Spotify::SyncTracksService.new(user).call
  end
end