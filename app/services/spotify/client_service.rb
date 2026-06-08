module Spotify
  # Thin wrapper around the Spotify Web API. Requires a valid Bearer token.
  class ClientService
    BASE_URL = 'https://api.spotify.com/v1'

    def initialize(token)
      @token = token
    end

    def me
      get('/me')
    end

    def liked_tracks(limit: 50, offset: 0)
      get('/me/tracks', limit: limit, offset: offset)
    end

    # Paginates through all pages and returns every liked track.
    def all_liked_tracks
      tracks = []
      offset = 0
      loop do
        response = liked_tracks(limit: 50, offset: offset)
        items = response['items']
        break unless items&.any?
        tracks += items
        break if tracks.size >= response['total']
        offset += 50
      end
      tracks
    end

    def create_playlist(user_id, name, description: '')
      post("/users/#{user_id}/playlists", { name: name, description: description, public: false })
    end

    # Spotify accepts at most 100 track URIs per request, so we batch automatically.
    def add_tracks_to_playlist(playlist_id, track_uris)
      track_uris.each_slice(100) do |batch|
        post("/playlists/#{playlist_id}/tracks", { uris: batch })
      end
    end

    private

    def get(path, params = {})
      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(params) if params.any?

      loop do
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = "Bearer #{@token}"
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        if response.code == '429'
          retry_after = response['Retry-After']&.to_i || 5
          Rails.logger.warn "Spotify rate limit hit, sleeping #{retry_after}s"
          sleep(retry_after)
          next
        end

        return JSON.parse(response.body)
      end
    end

    def post(path, body)
      uri = URI("#{BASE_URL}#{path}")
      req = Net::HTTP::Post.new(uri)
      req['Authorization'] = "Bearer #{@token}"
      req['Content-Type'] = 'application/json'
      req.body = body.to_json
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
      JSON.parse(response.body)
    end
  end
end
