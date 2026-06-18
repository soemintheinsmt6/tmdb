import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/favourites/data/models/favourite_tv_show.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';

import '../../../../helpers/tv_fixtures.dart';

void main() {
  group('FavouriteTvShow', () {
    test('round-trips a TV favourite through fromItem/toFavouriteItem', () {
      final item = FavouriteItem.fromTvShow(buildTvShow(id: 1399));

      final round = FavouriteTvShow.fromItem(item).toFavouriteItem();

      expect(round.mediaType, MediaType.tv);
      expect(round.id, 1399);
      expect(round.title, item.title); // TvShow.name → title
      expect(round.overview, item.overview);
      expect(round.posterPath, item.posterPath);
      expect(round.backdropPath, item.backdropPath);
      expect(round.date, item.date); // firstAirDate → date
      expect(round.voteAverage, item.voteAverage);
      expect(round.voteCount, item.voteCount);
      expect(round.savedAt, item.savedAt);
    });
  });
}
