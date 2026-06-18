import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:tmdb/shared/domain/library_sort.dart';

FavouriteItem _fav({
  int id = 1,
  String title = 'Title',
  double voteAverage = 0,
  String date = '',
  DateTime? savedAt,
}) {
  return FavouriteItem(
    mediaType: MediaType.movie,
    id: id,
    title: title,
    overview: '',
    posterPath: null,
    backdropPath: null,
    date: date,
    voteAverage: voteAverage,
    voteCount: 1,
    savedAt: savedAt ?? DateTime(2020),
  );
}

void main() {
  group('LibrarySort.comparator', () {
    test('recentlyAdded orders by savedAt, newest first', () {
      final items = [
        _fav(id: 1, savedAt: DateTime(2021)),
        _fav(id: 2, savedAt: DateTime(2023)),
        _fav(id: 3, savedAt: DateTime(2022)),
      ]..sort(LibrarySort.recentlyAdded.comparator);

      expect(items.map((i) => i.id), [2, 3, 1]);
    });

    test('title orders A–Z, case-insensitively', () {
      final items = [
        _fav(id: 1, title: 'banana'),
        _fav(id: 2, title: 'Apple'),
        _fav(id: 3, title: 'cherry'),
      ]..sort(LibrarySort.title.comparator);

      expect(items.map((i) => i.title), ['Apple', 'banana', 'cherry']);
    });

    test('topRated orders by score, highest first', () {
      final items = [
        _fav(id: 1, voteAverage: 5.0),
        _fav(id: 2, voteAverage: 9.0),
        _fav(id: 3, voteAverage: 7.0),
      ]..sort(LibrarySort.topRated.comparator);

      expect(items.map((i) => i.id), [2, 3, 1]);
    });

    test('releaseDate orders newest first, empty dates last', () {
      final items = [
        _fav(id: 1, date: '2010-01-01'),
        _fav(id: 2, date: ''),
        _fav(id: 3, date: '2020-05-01'),
      ]..sort(LibrarySort.releaseDate.comparator);

      expect(items.map((i) => i.id), [3, 1, 2]);
    });

    test('the same comparator sorts watchlist items (shared interface)', () {
      final items = <WatchlistItem>[
        WatchlistItem(
          mediaType: MediaType.tv,
          id: 1,
          title: 'Zed',
          overview: '',
          posterPath: null,
          backdropPath: null,
          date: '',
          voteAverage: 0,
          voteCount: 0,
          savedAt: DateTime(2020),
        ),
        WatchlistItem(
          mediaType: MediaType.tv,
          id: 2,
          title: 'Alpha',
          overview: '',
          posterPath: null,
          backdropPath: null,
          date: '',
          voteAverage: 0,
          voteCount: 0,
          savedAt: DateTime(2020),
        ),
      ]..sort(LibrarySort.title.comparator);

      expect(items.map((i) => i.title), ['Alpha', 'Zed']);
    });
  });
}
