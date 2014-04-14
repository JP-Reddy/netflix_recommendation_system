require_relative "./cluster_engine"
require_relative "./data_extractor"

class MovieRatingPredictor
  def predict_movie_rate_for_user(user, movie)
    user_movie_ratings = other_movie_ratings_by_user(user, movie)
    users_ratings = users_ratings_for_movie(movie)
    similar_users = get_similar_users_based_on_ratings(
      user, user_movie_ratings, users_ratings.keys)
    calculate_predicted_rating(users_ratings, similar_users)
  end

  def other_movie_ratings_by_user(user, movie)
    movies_ratings = {}
    DataExtractor.movies_rated_by_user(user) do |movie, rate|
      movies_ratings[movie] = rate
    end
    movies_ratings.reject { |movie_id, rate| movie_id == movie }
  end

  def users_ratings_for_movie(movie)
    users_ratings = {}
    DataExtractor.user_ratings_for_movie(movie) do |user_id, rate|
      users_ratings[user_id] = rate
    end
    users_ratings
  end

  def get_similar_users_based_on_ratings(user, user_movie_ratings, other_users)
    cluster_engine = ClusterEngine.new(user, user_movie_ratings, other_users)
    cluster_engine.similar_users
  end

  def calculate_predicted_rating(users_ratings, similar_users)
    sum = 0
    similar_users.each { |user_id| sum += users_ratings[user_id] }
    sum / similar_users.count.to_f
  end
end

movies = ["0008387", "0009049", "0010042", "0011283", "0012084", "0016139"]

if __FILE__ == $0
  movies.each do |movie|
    puts MovieRatingPredictor.new.
      predict_movie_rate_for_user("1003353", movie)
  end
end
