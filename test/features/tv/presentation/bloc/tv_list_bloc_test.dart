import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_state.dart';

import '../../../../helpers/tv_fixtures.dart';

class _MockTvRepository extends Mock implements TvRepository {}

void main() {
  late _MockTvRepository repository;

  setUp(() {
    repository = _MockTvRepository();
  });

  // The bloc fires TvListCategoryChanged(initialCategory) in its constructor,
  // so every test sees [Loading, Loaded] before the action under test. Tests
  // that exercise other behaviour use `skip: 2`.
  final initialPage = buildPaginatedTv(
    page: 1,
    totalPages: 3,
    shows: [buildTvShow(id: 1)],
  );

  void stubInitial({
    TvCategory category = TvCategory.popular,
    PaginatedTvShows? page,
  }) {
    when(
      () => repository.getTvShows(category: category, page: 1),
    ).thenAnswer((_) async => Right(page ?? initialPage));
  }

  group('initial category fetch', () {
    blocTest<TvListBloc, TvListState>(
      'emits Loading then Loaded for the initial category',
      setUp: stubInitial,
      build: () => TvListBloc(repository: repository),
      expect: () => [
        const TvListLoading(category: TvCategory.popular),
        TvListLoaded(
          category: TvCategory.popular,
          shows: initialPage.shows,
          page: 1,
          totalPages: 3,
        ),
      ],
    );

    blocTest<TvListBloc, TvListState>(
      'emits Loading then Error when the initial fetch fails',
      setUp: () {
        when(
          () => repository.getTvShows(category: TvCategory.popular, page: 1),
        ).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'oops', statusCode: 500)),
        );
      },
      build: () => TvListBloc(repository: repository),
      expect: () => const [
        TvListLoading(category: TvCategory.popular),
        TvListError(category: TvCategory.popular, message: 'oops'),
      ],
    );
  });

  group('TvListLoadMore', () {
    blocTest<TvListBloc, TvListState>(
      'appends the next page and clears the loading flag',
      setUp: () {
        stubInitial();
        when(
          () => repository.getTvShows(category: TvCategory.popular, page: 2),
        ).thenAnswer(
          (_) async => Right(
            buildPaginatedTv(
              page: 2,
              totalPages: 3,
              shows: [buildTvShow(id: 2)],
            ),
          ),
        );
      },
      build: () => TvListBloc(repository: repository),
      act: (bloc) => bloc.add(const TvListLoadMore()),
      skip: 2, // initial Loading + Loaded
      expect: () => [
        isA<TvListLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.shows.length, 'shows.length', 1),
        isA<TvListLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.page, 'page', 2)
            .having((s) => s.shows.map((m) => m.id).toList(), 'show ids', [
              1,
              2,
            ]),
      ],
    );

    blocTest<TvListBloc, TvListState>(
      'is a no-op when already on the last page',
      setUp: () => stubInitial(
        page: buildPaginatedTv(
          page: 1,
          totalPages: 1,
          shows: [buildTvShow(id: 1)],
        ),
      ),
      build: () => TvListBloc(repository: repository),
      act: (bloc) => bloc.add(const TvListLoadMore()),
      skip: 2,
      expect: () => const <TvListState>[],
      verify: (_) {
        verify(
          () => repository.getTvShows(category: TvCategory.popular, page: 1),
        ).called(1);
        verifyNever(
          () => repository.getTvShows(category: TvCategory.popular, page: 2),
        );
      },
    );

    blocTest<TvListBloc, TvListState>(
      'reverts the loading flag when the next page errors',
      setUp: () {
        stubInitial();
        when(
          () => repository.getTvShows(category: TvCategory.popular, page: 2),
        ).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'nope', statusCode: 500)),
        );
      },
      build: () => TvListBloc(repository: repository),
      act: (bloc) => bloc.add(const TvListLoadMore()),
      skip: 2,
      expect: () => [
        isA<TvListLoaded>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          true,
        ),
        isA<TvListLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.shows.length, 'shows.length', 1),
      ],
    );
  });

  group('TvListCategoryChanged', () {
    blocTest<TvListBloc, TvListState>(
      'switches category and refetches',
      setUp: () {
        stubInitial();
        when(
          () => repository.getTvShows(category: TvCategory.topRated, page: 1),
        ).thenAnswer(
          (_) async => Right(buildPaginatedTv(shows: [buildTvShow(id: 99)])),
        );
      },
      build: () => TvListBloc(repository: repository),
      act: (bloc) => bloc.add(const TvListCategoryChanged(TvCategory.topRated)),
      skip: 2,
      expect: () => [
        const TvListLoading(category: TvCategory.topRated),
        isA<TvListLoaded>()
            .having((s) => s.category, 'category', TvCategory.topRated)
            .having((s) => s.shows.first.id, 'first show id', 99),
      ],
    );
  });
}
