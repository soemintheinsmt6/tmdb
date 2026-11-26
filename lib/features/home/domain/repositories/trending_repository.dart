import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/home/domain/entities/paginated_trending.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

/// Repository abstraction for trending content. Concrete implementations live
/// in the data layer.
abstract class TrendingRepository {
  /// Mixed movie + TV trending titles (people omitted).
  ResultFuture<List<PosterItem>> getTrending({String window = 'day'});

  /// One page of mixed movie + TV trending titles, for the paged grid.
  ResultFuture<PaginatedTrending> getTrendingPage({
    int page = 1,
    String window = 'day',
  });

  /// Trending TV shows only.
  ResultFuture<List<TvShow>> getTrendingTv({String window = 'day'});
}
