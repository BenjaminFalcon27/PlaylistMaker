# Spotify Playlist App

A Rails 8 API that connects to Spotify via OAuth2 to sync a user's liked tracks and generate playlists through AI classification.

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Ruby 3.3 / Rails 8.1 |
| Database | PostgreSQL (JSONB for audio features) |
| Auth | OAuth2 — Spotify authorization code flow |
| Background jobs | Solid Queue |
| Deployment | Docker / Kamal |

## Prerequisites

- Ruby 3.3.x
- PostgreSQL
- A [Spotify Developer](https://developer.spotify.com/dashboard) app with a registered redirect URI

## Setup

```bash
git clone <repo-url>
cd spotify-playlist-app

cp .env.example .env        # fill in your Spotify credentials

bundle install
bin/rails db:create db:migrate
bin/rails server
```

Or with Docker:

```bash
docker compose up
```

## Environment Variables

| Variable | Description |
|---|---|
| `SPOTIFY_CLIENT_ID` | Spotify app client ID |
| `SPOTIFY_CLIENT_SECRET` | Spotify app client secret |
| `SPOTIFY_REDIRECT_URI` | Callback URL registered in Spotify dashboard |

> Copy `.env.example` to `.env` and fill in the values. Never commit `.env`.

## API Endpoints

| Method | Path | Auth required | Description |
|---|---|---|---|
| `GET` | `/auth/spotify` | No | Redirect to Spotify authorization |
| `GET` | `/auth/spotify/callback` | No | OAuth2 callback — creates or updates the user session |
| `GET` | `/tracks/liked` | Yes | Return the authenticated user's liked tracks |

Authentication is session-based. After a successful OAuth callback the user ID is stored in the session; any controller that `include SpotifyAuthenticable` enforces it.

## Data Model

```
User
 ├── has_many :tracks              # liked tracks synced from Spotify
 └── has_many :generated_playlists
       └── has_many :playlist_tracks
```

**`Track`** — raw Spotify metadata (title, artist, album, duration, popularity, audio features as JSONB).

**`GeneratedPlaylist`** — result of an AI classification pass. The `classifier` field records which model/strategy was used. Each playlist snapshots its tracks in `PlaylistTrack`.

## Running Tests

```bash
bin/rails test
```

## Project Structure

```
app/
├── controllers/
│   ├── concerns/spotify_authenticable.rb   # session auth + token refresh
│   ├── spotify_auth_controller.rb          # OAuth2 flow
│   └── tracks_controller.rb
├── models/
│   ├── user.rb
│   ├── track.rb
│   ├── generated_playlist.rb
│   └── playlist_track.rb
└── services/
    └── spotify/
        ├── client_service.rb               # Spotify Web API wrapper
        └── sync_tracks_service.rb          # incremental liked-tracks sync
```
