Rails.application.routes.draw do
  get '/auth/spotify', to: 'spotify_auth#authorize'
  get '/auth/spotify/callback', to: 'spotify_auth#callback'
  get '/tracks/liked', to: 'tracks#liked'
  post '/tracks/sync', to: 'tracks#sync'
  get '/tracks/sync', to: 'tracks#sync'
  get '/tracks/full_sync', to: 'tracks#full_sync'
  get '/tracks/fetch_genres', to: 'tracks#fetch_genres'
  get '/tracks/genres_status', to: 'tracks#genres_status'

  get '/classifiers/preview', to: 'classifiers#preview'
  get '/classifiers/stats', to: 'classifiers#stats'

  post '/playlists/generate', to: 'playlists#generate'
end