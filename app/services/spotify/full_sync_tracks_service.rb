module Spotify
  class FullSyncTracksService
    def initialize(user)
      @user = user
      refresh_token_if_needed!
      @client = Spotify::ClientService.new(user.spotify_token)
    end

    def call
      spotify_ids = fetch_all_spotify_ids
      upsert_all_tracks(spotify_ids[:items])
      purge_unliked(spotify_ids[:ids])
      @user.update!(last_synced_at: Time.now)
    end

    private

    def fetch_all_spotify_ids
      items = []
      ids = []
      offset = 0
      loop do
        response = @client.liked_tracks(limit: 50, offset: offset)
        Rails.logger.debug "Spotify response total: #{response['total']}, items: #{response['items']&.size}"
        batch = response['items']
        break unless batch&.any?
        items += batch
        ids += batch.filter_map { |i| i.dig('track', 'id') }
        sleep(0.1)
        break if items.size >= response['total']
        offset += 50
      end
      Rails.logger.debug "Total fetched: #{items.size}, ids: #{ids.size}"
      { items: items, ids: ids }
    end

    def upsert_all_tracks(items)
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

    def purge_unliked(spotify_ids)
      @user.tracks.where.not(spotify_id: spotify_ids).destroy_all
    end

    def refresh_token_if_needed!
      return if @user.token_expires_at.nil? || @user.token_expires_at > Time.now

      client = OAuth2::Client.new(
        ENV['SPOTIFY_CLIENT_ID'],
        ENV['SPOTIFY_CLIENT_SECRET'],
        site: 'https://accounts.spotify.com',
        token_url: '/api/token'
      )

      new_token = client.get_token(
        grant_type: 'refresh_token',
        refresh_token: @user.spotify_refresh_token,
        auth_scheme: :request_body
      )

      @user.update!(
        spotify_token: new_token.token,
        token_expires_at: Time.at(new_token.expires_at)
      )
    end
  end
end