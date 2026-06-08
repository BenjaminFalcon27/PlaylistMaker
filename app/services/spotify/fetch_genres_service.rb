module Spotify
  # Fetches artist genres from Last.fm (Spotify's artist API restricts genre data).
  class FetchGenresService
    LASTFM_URL = 'https://ws.audioscrobbler.com/2.0/'

    def initialize(user)
      @user = user
    end

    def call
      artist_names = @user.tracks.where(genres: nil).pluck(:artist_name, :artist_id).uniq(&:first)

      artist_names.each do |artist_name, artist_id|
        genres = fetch_genres_from_lastfm(artist_name)
        next if genres.nil?

        @user.tracks.where(artist_id: artist_id, genres: nil)
                    .update_all(["genres = ?::jsonb", genres.to_json])

        sleep(0.2)
      end
    end

    private

    def fetch_genres_from_lastfm(artist_name)
      uri = URI(LASTFM_URL)
      uri.query = URI.encode_www_form(
        method: 'artist.getinfo',
        artist: artist_name,
        api_key: ENV['LASTFM_API_KEY'],
        format: 'json'
      )

      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)

      return nil if data['error']

      tags = data.dig('artist', 'tags', 'tag') || []
      tags = [tags] if tags.is_a?(Hash)
      tags.map { |t| t['name'].downcase }.first(5)
    rescue StandardError
      nil
    end
  end
end
