import 'package:equatable/equatable.dart';
import 'package:tmdb/shared/domain/media_type.dart';

export 'package:tmdb/shared/domain/media_type.dart';

/// A title the user has engaged with (favourited or watchlisted) used as a
/// seed for personalised "For You" recommendations.
class RecommendationSeed extends Equatable {
  const RecommendationSeed({required this.type, required this.id});

  final MediaType type;
  final int id;

  /// Composite key matching the favourites/watchlist `storageKey` format
  /// (`"movie:550"` / `"tv:1399"`), so seeds and saved items share one
  /// namespace for exclusion.
  String get key => '${type.name}:$id';

  @override
  List<Object?> get props => [type, id];
}
