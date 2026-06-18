import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';

import '../../../../helpers/movie_fixtures.dart';
import '../../../../helpers/tv_fixtures.dart';

void main() {
  group('FavouritesState', () {
    test('default state is empty', () {
      const state = FavouritesState();

      expect(state.items, isEmpty);
      expect(state.keys, isEmpty);
    });

    test('fromItems derives composite keys', () {
      final state = FavouritesState.fromItems([
        FavouriteItem.fromMovie(buildMovie(id: 1)),
        FavouriteItem.fromTvShow(buildTvShow(id: 7)),
      ]);

      expect(state.items, hasLength(2));
      expect(state.keys, {'movie:1', 'tv:7'});
    });

    test('contains respects the media type', () {
      final state = FavouritesState.fromItems([
        FavouriteItem.fromMovie(buildMovie(id: 7)),
      ]);

      expect(state.contains(MediaType.movie, 7), isTrue);
      expect(state.contains(MediaType.tv, 7), isFalse);
    });

    test('a movie and a TV show with the same id do not collide', () {
      final state = FavouritesState.fromItems([
        FavouriteItem.fromMovie(buildMovie(id: 5)),
        FavouriteItem.fromTvShow(buildTvShow(id: 5)),
      ]);

      expect(state.keys, {'movie:5', 'tv:5'});
      expect(state.contains(MediaType.movie, 5), isTrue);
      expect(state.contains(MediaType.tv, 5), isTrue);
    });

    test('Equatable: same membership is equal, differing is not', () {
      final a = FavouritesState.fromItems([
        FavouriteItem.fromMovie(buildMovie(id: 1)),
      ]);
      final b = FavouritesState.fromItems([
        FavouriteItem.fromMovie(buildMovie(id: 1)),
      ]);
      final c = FavouritesState.fromItems([
        FavouriteItem.fromMovie(buildMovie(id: 2)),
      ]);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
