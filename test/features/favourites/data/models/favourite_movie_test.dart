import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';

import '../../../../helpers/movie_fixtures.dart';

void main() {
  group('FavouriteMovie.fromMovie', () {
    test('copies the persisted fields and stamps savedAt to roughly now', () {
      final movie = buildMovie(id: 42);
      final before = DateTime.now();

      final fav = FavouriteMovie.fromMovie(movie);

      final after = DateTime.now();
      expect(fav.movieId, movie.id);
      expect(fav.title, movie.title);
      expect(fav.overview, movie.overview);
      expect(fav.posterPath, movie.posterPath);
      expect(fav.backdropPath, movie.backdropPath);
      expect(fav.releaseDate, movie.releaseDate);
      expect(fav.voteAverage, movie.voteAverage);
      expect(fav.voteCount, movie.voteCount);
      // ObjectBox `id` only gets assigned on `_box.put`.
      expect(fav.id, 0);
      expect(
        fav.savedAt.isBefore(before.subtract(const Duration(seconds: 1))),
        isFalse,
      );
      expect(
        fav.savedAt.isAfter(after.add(const Duration(seconds: 1))),
        isFalse,
      );
    });
  });

  group('FavouriteMovie.toMovie', () {
    test('round-trips most fields', () {
      final original = buildMovie(id: 100);

      final round = FavouriteMovie.fromMovie(original).toMovie();

      expect(round.id, original.id);
      expect(round.title, original.title);
      expect(round.overview, original.overview);
      expect(round.posterPath, original.posterPath);
      expect(round.backdropPath, original.backdropPath);
      expect(round.releaseDate, original.releaseDate);
      expect(round.voteAverage, original.voteAverage);
      expect(round.voteCount, original.voteCount);
    });

    test('drops genreIds — favourites do not persist them', () {
      final original = buildMovie(id: 1, genreIds: const [18, 53]);

      final round = FavouriteMovie.fromMovie(original).toMovie();

      expect(round.genreIds, isEmpty);
    });
  });
}
