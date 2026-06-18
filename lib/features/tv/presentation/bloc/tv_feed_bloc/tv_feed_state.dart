import 'package:equatable/equatable.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';

enum TvFeedStatus { initial, loading, loaded, error }

/// Single immutable state for the editorial series landing. Each rail is
/// independent and best-effort: a rail whose fetch failed is empty (and
/// hidden). [status] only goes to [TvFeedStatus.error] when every rail failed.
class TvFeedState extends Equatable {
  const TvFeedState({
    this.status = TvFeedStatus.initial,
    this.trending = const [],
    this.popular = const [],
    this.topRated = const [],
    this.onTheAir = const [],
    this.airingToday = const [],
    this.message = '',
  });

  final TvFeedStatus status;

  /// Trending TV — first item drives the hero, the rest fill the trending rail.
  final List<TvShow> trending;
  final List<TvShow> popular;
  final List<TvShow> topRated;
  final List<TvShow> onTheAir;
  final List<TvShow> airingToday;
  final String message;

  TvFeedState copyWith({
    TvFeedStatus? status,
    List<TvShow>? trending,
    List<TvShow>? popular,
    List<TvShow>? topRated,
    List<TvShow>? onTheAir,
    List<TvShow>? airingToday,
    String? message,
  }) {
    return TvFeedState(
      status: status ?? this.status,
      trending: trending ?? this.trending,
      popular: popular ?? this.popular,
      topRated: topRated ?? this.topRated,
      onTheAir: onTheAir ?? this.onTheAir,
      airingToday: airingToday ?? this.airingToday,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    trending,
    popular,
    topRated,
    onTheAir,
    airingToday,
    message,
  ];
}
