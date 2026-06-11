import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';

/// The TMDB TV list endpoints exposed in the TV screen tabs.
enum TvCategory { popular, topRated, onTheAir, airingToday }

/// Repository abstraction the rest of the app depends on. Concrete
/// implementations live in the data layer.
abstract class TvRepository {
  ResultFuture<PaginatedTvShows> getTvShows({
    required TvCategory category,
    int page = 1,
  });

  ResultFuture<PaginatedTvShows> searchTvShows({
    required String query,
    int page = 1,
  });

  ResultFuture<TvShowDetail> getTvShowDetail(int id);
}
