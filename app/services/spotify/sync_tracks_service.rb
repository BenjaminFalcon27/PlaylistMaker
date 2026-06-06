module Spotify
  class SyncTracksService
    def initialize(user)
      @user = user
      @client = Spotify::ClientService.new(user.spotify_token)
    end

    def call
      tracks = fetch_new_tracks
      upsert_tracks(tracks)
      if tracks.any?
        last_added_at = tracks.map { |i| Time.parse(i['added_at']) }.max
        @user.update!(last_synced_at: last_added_at)
      end
      tracks.size
    end

    private

    def fetch_new_tracks
      tracks = []
      offset = 0
      loop do
        response = @client.liked_tracks(limit: 50, offset: offset)
        items = response['items']
        break unless items&.any?
        new_items = items.select do |item|
          added_at = Time.parse(item['added_at'])
          @user.last_synced_at.nil? || added_at >= @user.last_synced_at
        end
        tracks += new_items
        break if new_items.size < items.size
        break if tracks.size >= response['total']
        offset += 50
      end
      tracks
    end

    def upsert_tracks(items)
      records = items.filter_map do |item|
        t = item['track']
        next unless t && t['id']
        {
          user_id: @user.id,
          spotify_id: t['id'],
          title: t['name'],
          artist_name: t.dig('artists', 0, 'name'),
          artist_id: t.dig('artists', 0, 'id'),
          album_name: t.dig('album', 'name'),
          added_at: item['added_at'],
          duration_ms: t['duration_ms'],
          popularity: t['popularity'],
          release_date: t.dig('album', 'release_date'),
          preview_url: t['preview_url'],
          created_at: Time.now,
          updated_at: Time.now
        }
      end
      Track.upsert_all(records, unique_by: :spotify_id) if records.any?
    end
  end
end