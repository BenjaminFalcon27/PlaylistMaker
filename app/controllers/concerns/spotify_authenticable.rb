module SpotifyAuthenticable
  extend ActiveSupport::Concern

  included do
    before_action :require_spotify_auth
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_spotify_auth
    redirect_to '/auth/spotify' unless current_user
  end

  def spotify_client
    refresh_token_if_needed!
    @spotify_client ||= Spotify::ClientService.new(current_user.spotify_token)
  end

  def refresh_token_if_needed!
    return if current_user.token_expires_at.nil? || current_user.token_expires_at > Time.now
    return unless current_user.token_expires_at < Time.now

    client = OAuth2::Client.new(
      ENV['SPOTIFY_CLIENT_ID'],
      ENV['SPOTIFY_CLIENT_SECRET'],
      site: 'https://accounts.spotify.com',
      token_url: '/api/token'
    )

    new_token = client.get_token(
      grant_type: 'refresh_token',
      refresh_token: current_user.spotify_refresh_token,
      auth_scheme: :request_body
    )

    current_user.update!(
      spotify_token: new_token.token,
      token_expires_at: Time.at(new_token.expires_at)
    )
  end
end