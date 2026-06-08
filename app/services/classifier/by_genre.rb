module Classifier
  class ByGenre
    def initialize(user)
      @user = user
    end

    def call
      @user.tracks.all.group_by do |track|
        genres = track.genres
        genres.is_a?(Array) && genres.any? ? genres.first : 'Unknown'
      end
    end
  end
end
