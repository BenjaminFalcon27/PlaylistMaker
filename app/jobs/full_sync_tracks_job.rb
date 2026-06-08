class FullSyncTracksJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    Spotify::FullSyncTracksService.new(user).call
  end
end