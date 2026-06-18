import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/watchlist/data/models/watchlist_entry.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';

import '../../../../helpers/movie_fixtures.dart';
import '../../../../helpers/tv_fixtures.dart';

void main() {
  group('WatchlistEntry', () {
    test('round-trips a movie item through fromItem/toItem', () {
      final item = WatchlistItem.fromMovie(buildMovie(id: 42));

      final round = WatchlistEntry.fromItem(item).toItem();

      expect(round.mediaType, MediaType.movie);
      expect(round.id, item.id);
      expect(round.title, item.title);
      expect(round.overview, item.overview);
      expect(round.posterPath, item.posterPath);
      expect(round.backdropPath, item.backdropPath);
      expect(round.date, item.date);
      expect(round.voteAverage, item.voteAverage);
      expect(round.voteCount, item.voteCount);
      expect(round.savedAt, item.savedAt);
    });

    test('round-trips a TV item and preserves the media type', () {
      final item = WatchlistItem.fromTvShow(buildTvShow(id: 1399));

      final round = WatchlistEntry.fromItem(item).toItem();

      expect(round.mediaType, MediaType.tv);
      expect(round.id, 1399);
      expect(round.title, item.title); // TvShow.name → title
      expect(round.date, item.date); // firstAirDate → date
    });

    test('stores the media type by index', () {
      final movie = WatchlistEntry.fromItem(
        WatchlistItem.fromMovie(buildMovie()),
      );
      final tv = WatchlistEntry.fromItem(
        WatchlistItem.fromTvShow(buildTvShow()),
      );

      expect(movie.mediaTypeIndex, MediaType.movie.index);
      expect(tv.mediaTypeIndex, MediaType.tv.index);
    });
  });
}
