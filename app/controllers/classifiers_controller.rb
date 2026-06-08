class ClassifiersController < ApplicationController
  include SpotifyAuthenticable

  def preview
    groups = Classifier::ByGenre.new(current_user).call
    result = groups.transform_values do |tracks|
      {
        count: tracks.size,
        sample: tracks.first(3).map { |t| { id: t.id, title: t.title, artist_name: t.artist_name } }
      }
    end
    render json: result
  end

  def stats
    counts = current_user.tracks
      .where.not(genres: nil)
      .where("genres != '[]'::jsonb")
      .group("genres->>0")
      .order(Arel.sql("COUNT(*) DESC"))
      .count

    render json: {
      total_with_genre: counts.values.sum,
      total_without_genre: current_user.tracks.where("genres IS NULL OR genres = '[]'::jsonb").count,
      genre_count: counts.size,
      distribution: counts
    }
  end
end
