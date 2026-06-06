Rails.application.routes.draw do
  get '/auth/spotify', to: 'spotify_auth#authorize'
  get '/auth/spotify/callback', to: 'spotify_auth#callback'
  get '/tracks/liked', to: 'tracks#liked'
end