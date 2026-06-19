import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_state.dart';

import '../../../../helpers/tv_fixtures.dart'
    show buildTvShow, buildPaginatedTv;

class _MockTv extends Mock implements TvRepository {}

class _MockTrending extends Mock implements TrendingRepository {}

void main() {
  late _MockTv tv;
  late _MockTrending trending;

  Either<Failure, PaginatedTvShows> tvOk(int id) =>
      Right(buildPaginatedTv(shows: [buildTvShow(id: id)]));

  setUp(() {
    tv = _MockTv();
    trending = _MockTrending();

    when(() => trending.getTrendingTv()).thenAnswer(
      (_) async => Right<Failure, List<TvShow>>([
        buildTvShow(id: 1),
        buildTvShow(id: 2),
      ]),
    );
    when(
      () => tv.getTvShows(category: TvCategory.popular),
    ).thenAnswer((_) async => tvOk(10));
    when(
      () => tv.getTvShows(category: TvCategory.topRated),
    ).thenAnswer((_) async => tvOk(11));
    when(
      () => tv.getTvShows(category: TvCategory.onTheAir),
    ).thenAnswer((_) async => tvOk(12));
    when(
      () => tv.getTvShows(category: TvCategory.airingToday),
    ).thenAnswer((_) async => tvOk(13));
  });

  TvFeedBloc build() =>
      TvFeedBloc(tvRepository: tv, trendingRepository: trending);

  blocTest<TvFeedBloc, TvFeedState>(
    'emits loading then loaded with a hero source and every rail',
    build: build,
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<TvFeedState>().having(
        (s) => s.status,
        'status',
        TvFeedStatus.loading,
      ),
      isA<TvFeedState>()
          .having((s) => s.status, 'status', TvFeedStatus.loaded)
          .having((s) => s.trending.map((e) => e.id), 'trending', [1, 2])
          .having((s) => s.popular.map((e) => e.id), 'popular', [10])
          .having((s) => s.topRated.map((e) => e.id), 'topRated', [11])
          .having((s) => s.onTheAir.map((e) => e.id), 'onTheAir', [12])
          .having((s) => s.airingToday.map((e) => e.id), 'airingToday', [13]),
    ],
  );

  blocTest<TvFeedBloc, TvFeedState>(
    'goes to error only when every rail fails',
    setUp: () {
      const failure = NetworkFailure(message: 'offline');
      when(
        () => trending.getTrendingTv(),
      ).thenAnswer((_) async => const Left<Failure, List<TvShow>>(failure));
      for (final c in TvCategory.values) {
        when(() => tv.getTvShows(category: c)).thenAnswer(
          (_) async => const Left<Failure, PaginatedTvShows>(failure),
        );
      }
    },
    build: build,
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<TvFeedState>().having(
        (s) => s.status,
        'status',
        TvFeedStatus.loading,
      ),
      isA<TvFeedState>()
          .having((s) => s.status, 'status', TvFeedStatus.error)
          .having((s) => s.message, 'message', 'offline'),
    ],
  );
}
