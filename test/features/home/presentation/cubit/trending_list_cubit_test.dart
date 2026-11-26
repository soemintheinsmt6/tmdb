import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/home/domain/entities/paginated_trending.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/home/presentation/cubit/trending_list_cubit.dart';
import 'package:tmdb/features/home/presentation/cubit/trending_list_state.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

import '../../../../helpers/movie_fixtures.dart' show buildMovie;
import '../../../../helpers/tv_fixtures.dart' show buildTvShow;

class _MockTrending extends Mock implements TrendingRepository {}

void main() {
  late _MockTrending repo;

  setUp(() => repo = _MockTrending());

  final page1 = PaginatedTrending(
    items: <PosterItem>[buildMovie(id: 1), buildTvShow(id: 2)],
    page: 1,
    totalPages: 3,
  );

  void stubPage(int page, Either<Failure, PaginatedTrending> result) {
    when(
      () => repo.getTrendingPage(page: page),
    ).thenAnswer((_) async => result);
  }

  blocTest<TrendingListCubit, TrendingListState>(
    'load emits loading then the first page',
    setUp: () => stubPage(1, Right(page1)),
    build: () => TrendingListCubit(repo),
    act: (c) => c.load(),
    expect: () => [
      const TrendingListState(status: TrendingListStatus.loading),
      TrendingListState(
        status: TrendingListStatus.loaded,
        items: page1.items,
        page: 1,
        totalPages: 3,
      ),
    ],
  );

  blocTest<TrendingListCubit, TrendingListState>(
    'load emits an error with the failure message',
    setUp: () =>
        stubPage(1, const Left(NetworkFailure(message: 'No connection'))),
    build: () => TrendingListCubit(repo),
    act: (c) => c.load(),
    expect: () => const [
      TrendingListState(status: TrendingListStatus.loading),
      TrendingListState(
        status: TrendingListStatus.error,
        message: 'No connection',
      ),
    ],
  );

  blocTest<TrendingListCubit, TrendingListState>(
    'loadMore appends the next page, dropping titles already shown',
    setUp: () => stubPage(
      2,
      Right(
        PaginatedTrending(
          // movie 1 repeats from page 1 → dropped; movie 2 shares tv 2's id
          // but is a different title → kept; tv 4 is new → kept.
          items: <PosterItem>[
            buildMovie(id: 1),
            buildMovie(id: 2),
            buildTvShow(id: 4),
          ],
          page: 2,
          totalPages: 3,
        ),
      ),
    ),
    build: () => TrendingListCubit(repo),
    seed: () => TrendingListState(
      status: TrendingListStatus.loaded,
      items: page1.items,
      page: 1,
      totalPages: 3,
    ),
    act: (c) => c.loadMore(),
    verify: (c) {
      expect(c.state.isLoadingMore, isFalse);
      expect(c.state.page, 2);
      expect(c.state.items.map((e) => '${e.runtimeType}:${e.id}'), [
        'Movie:1',
        'TvShow:2',
        'Movie:2',
        'TvShow:4',
      ]);
    },
  );

  blocTest<TrendingListCubit, TrendingListState>(
    'loadMore does nothing on the last page',
    build: () => TrendingListCubit(repo),
    seed: () => TrendingListState(
      status: TrendingListStatus.loaded,
      items: page1.items,
      page: 3,
      totalPages: 3,
    ),
    act: (c) => c.loadMore(),
    expect: () => const <TrendingListState>[],
    verify: (_) =>
        verifyNever(() => repo.getTrendingPage(page: any(named: 'page'))),
  );

  blocTest<TrendingListCubit, TrendingListState>(
    'loadMore failure keeps the loaded items',
    setUp: () =>
        stubPage(2, const Left(NetworkFailure(message: 'No connection'))),
    build: () => TrendingListCubit(repo),
    seed: () => TrendingListState(
      status: TrendingListStatus.loaded,
      items: page1.items,
      page: 1,
      totalPages: 3,
    ),
    act: (c) => c.loadMore(),
    verify: (c) {
      expect(c.state.status, TrendingListStatus.loaded);
      expect(c.state.items, page1.items);
      expect(c.state.page, 1);
      expect(c.state.isLoadingMore, isFalse);
    },
  );
}
