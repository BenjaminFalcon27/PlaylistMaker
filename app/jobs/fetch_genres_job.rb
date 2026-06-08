class FetchGenresJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    Spotify::FetchGenresService.new(user).call
  end
end
