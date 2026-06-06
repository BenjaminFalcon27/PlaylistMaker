module Spotify
  # Fetches liked tracks added since the user's last sync and persists them.
  class SyncTracksService
    def initialize(user)
      @user = user
      @client = Spotify::ClientService.new(user.spotify_token)
    end

    # Returns the number of newly synced tracks.
    def call
      tracks = fetch_new_tracks
      upsert_tracks(tracks)
      @user.update!(last_synced_at: Time.now)
      tracks.size
    end

    private

    # Stops paginating as soon as it hits a track older than last_synced_at.
    def fetch_new_tracks
      tracks = []
      offset = 0

      loop do
        response = @client.liked_tracks(limit: 50, offset: offset)
        items = response['items']
        break unless items&.any?

        new_items = items.select do |item|
          added_at = Time.parse(item['added_at'])
          @user.last_synced_at.nil? || added_at > @user.last_synced_at
        end

        tracks += new_items
        break if new_items.size < items.size
        break if tracks.size >= response['total']
        offset += 50
      end

      tracks
    end

    def upsert_tracks(items)
      items.each do |item|
        t = item['track']
        next unless t && t['id']

        @user.tracks.find_or_initialize_by(spotify_id: t['id']).tap do |track|
          track.assign_attributes(
            title: t['name'],
            artist_name: t.dig('artists', 0, 'name'),
            artist_id: t.dig('artists', 0, 'id'),
            album_name: t.dig('album', 'name'),
            added_at: item['added_at'],
            duration_ms: t['duration_ms'],
            popularity: t['popularity'],
            release_date: t.dig('album', 'release_date'),
            preview_url: t['preview_url']
          )
          track.save!
        end
      end
    end
  end
end
