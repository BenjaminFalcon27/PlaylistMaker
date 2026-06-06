class SpotifyAuthController < ApplicationController
  SPOTIFY_AUTH_URL = 'https://accounts.spotify.com/authorize'
  SPOTIFY_TOKEN_URL = 'https://accounts.spotify.com/api/token'
  # All scopes required for reading liked tracks, user profile, and managing playlists.
  SCOPES = 'user-library-read user-read-private user-read-email playlist-modify-public playlist-modify-private user-top-read user-read-recently-played'

  def authorize
    params = {
      client_id: ENV['SPOTIFY_CLIENT_ID'],
      response_type: 'code',
      redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
      scope: SCOPES
    }
    redirect_to "#{SPOTIFY_AUTH_URL}?#{params.to_query}", allow_other_host: true
  end

  def callback
    return render json: { error: 'No code provided' }, status: :bad_request unless params[:code]

    code = params[:code]

    client = OAuth2::Client.new(
      ENV['SPOTIFY_CLIENT_ID'],
      ENV['SPOTIFY_CLIENT_SECRET'],
      site: 'https://accounts.spotify.com',
      token_url: '/api/token'
    )

    token_response = client.auth_code.get_token(
      code,
      redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
      auth_scheme: :request_body
    )

    spotify_client = Spotify::ClientService.new(token_response.token)
    profile = spotify_client.me

    user = User.find_or_initialize_by(spotify_uid: profile['id'])
    user.update!(
      spotify_token: token_response.token,
      spotify_refresh_token: token_response.refresh_token,
      token_expires_at: Time.at(token_response.expires_at),
      display_name: profile['display_name'],
      email: profile['email'],
      avatar_url: profile.dig('images', 0, 'url')
    )

    session[:user_id] = user.id

    render json: { status: 'ok', user: { id: user.id, display_name: user.display_name } }
  rescue OAuth2::Error => e
    render json: { error: 'Auth failed, please retry', detail: e.message }, status: :unauthorized
  end
end
