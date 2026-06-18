import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/recommendations/domain/entities/recommendation_seed.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

/// Builds a personalised feed from the titles the user has saved.
abstract class RecommendationsRepository {
  /// Fans out TMDB `/recommendations` over [seeds], aggregates the results by
  /// how many seeds recommend each title, then ranks (frequency first, rating
  /// as a tie-breaker). Titles whose key (`"movie:550"`) is in [excludeKeys] —
  /// plus the seeds themselves — are dropped, so nothing already saved is
  /// recommended back.
  ///
  /// Best-effort: a single seed's failed fetch is skipped. A [Failure] is
  /// returned only when there are seeds but *every* fetch failed; an empty
  /// [seeds] list resolves to an empty result, not an error.
  ResultFuture<List<PosterItem>> getForYou({
    required List<RecommendationSeed> seeds,
    Set<String> excludeKeys,
    int limit,
  });
}
