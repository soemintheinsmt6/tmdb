import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';

import '../../../../helpers/movie_fixtures.dart';

void main() {
  group('FavouritesState', () {
    test('default state is empty', () {
      const state = FavouritesState();

      expect(state.movies, isEmpty);
      expect(state.ids, isEmpty);
    });

    test('fromMovies derives ids from movie IDs', () {
      final state = FavouritesState.fromMovies([
        buildMovie(id: 1),
        buildMovie(id: 7),
        buildMovie(id: 42),
      ]);

      expect(state.movies, hasLength(3));
      expect(state.ids, {1, 7, 42});
    });

    test('contains is O(1) and reflects membership', () {
      final state = FavouritesState.fromMovies([buildMovie(id: 7)]);

      expect(state.contains(7), isTrue);
      expect(state.contains(8), isFalse);
    });

    test('Equatable: two states with the same movies are equal', () {
      final a = FavouritesState.fromMovies([buildMovie(id: 1)]);
      final b = FavouritesState.fromMovies([buildMovie(id: 1)]);

      expect(a, equals(b));
    });

    test('Equatable: differing membership is not equal', () {
      final a = FavouritesState.fromMovies([buildMovie(id: 1)]);
      final b = FavouritesState.fromMovies([buildMovie(id: 2)]);

      expect(a, isNot(equals(b)));
    });
  });
}
