import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

enum HomeStatus { initial, loading, loaded, error }

/// Single immutable state for the editorial home. Each rail is independent and
/// best-effort: a rail whose fetch failed is simply empty (and hidden). The
/// page-level [status] only goes to [HomeStatus.error] when every core rail
/// failed (e.g. offline at first load).
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.trending = const [],
    this.forYou = const [],
    this.nowPlaying = const [],
    this.topRated = const [],
    this.upcoming = const [],
    this.popularSeries = const [],
    this.message = '',
  });

  final HomeStatus status;

  /// Mixed movie + TV trending titles — first item drives the hero.
  final List<PosterItem> trending;

  /// Personalised rail; empty when the user has saved nothing yet (hidden).
  final List<PosterItem> forYou;
  final List<Movie> nowPlaying;
  final List<Movie> topRated;
  final List<Movie> upcoming;
  final List<TvShow> popularSeries;
  final String message;

  HomeState copyWith({
    HomeStatus? status,
    List<PosterItem>? trending,
    List<PosterItem>? forYou,
    List<Movie>? nowPlaying,
    List<Movie>? topRated,
    List<Movie>? upcoming,
    List<TvShow>? popularSeries,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      trending: trending ?? this.trending,
      forYou: forYou ?? this.forYou,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      topRated: topRated ?? this.topRated,
      upcoming: upcoming ?? this.upcoming,
      popularSeries: popularSeries ?? this.popularSeries,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    trending,
    forYou,
    nowPlaying,
    topRated,
    upcoming,
    popularSeries,
    message,
  ];
}
