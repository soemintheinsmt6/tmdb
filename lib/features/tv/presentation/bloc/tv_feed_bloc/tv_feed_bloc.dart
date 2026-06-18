import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

import 'tv_feed_event.dart';
import 'tv_feed_state.dart';

/// Aggregates the series landing rails (trending hero + the four TV
/// categories), best-effort, mirroring `HomeBloc` for the TV vertical.
class TvFeedBloc extends Bloc<TvFeedEvent, TvFeedState> {
  TvFeedBloc({
    required TvRepository tvRepository,
    required TrendingRepository trendingRepository,
  }) : _tv = tvRepository,
       _trending = trendingRepository,
       super(const TvFeedState()) {
    on<TvFeedStarted>((_, emit) => _load(emit, initial: true));
    on<TvFeedRefreshed>((_, emit) => _load(emit, initial: false));

    add(const TvFeedStarted());
  }

  final TvRepository _tv;
  final TrendingRepository _trending;

  Future<void> _load(Emitter<TvFeedState> emit, {required bool initial}) async {
    if (initial) emit(state.copyWith(status: TvFeedStatus.loading));

    final trendingF = _trending.getTrendingTv();
    final popularF = _tv.getTvShows(category: TvCategory.popular);
    final topF = _tv.getTvShows(category: TvCategory.topRated);
    final airF = _tv.getTvShows(category: TvCategory.onTheAir);
    final todayF = _tv.getTvShows(category: TvCategory.airingToday);

    final trendingE = await trendingF;
    final popularE = await popularF;
    final topE = await topF;
    final airE = await airF;
    final todayE = await todayF;

    final anyCore =
        trendingE.isRight() ||
        popularE.isRight() ||
        topE.isRight() ||
        airE.isRight() ||
        todayE.isRight();

    if (!anyCore) {
      emit(
        state.copyWith(
          status: TvFeedStatus.error,
          message: _firstError([trendingE, popularE, topE, airE, todayE]),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TvFeedStatus.loaded,
        message: '',
        trending: trendingE.getOrElse(() => const []),
        popular: popularE.fold((_) => const [], (p) => p.shows),
        topRated: topE.fold((_) => const [], (p) => p.shows),
        onTheAir: airE.fold((_) => const [], (p) => p.shows),
        airingToday: todayE.fold((_) => const [], (p) => p.shows),
      ),
    );
  }

  String _firstError(List<Either<Failure, dynamic>> results) {
    for (final r in results) {
      final message = r.fold<String?>((f) => f.message, (_) => null);
      if (message != null) return message;
    }
    return 'Something went wrong.';
  }
}
