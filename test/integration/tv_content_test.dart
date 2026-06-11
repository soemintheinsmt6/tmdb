import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_bloc.dart';
import 'package:tmdb/features/tv/presentation/widgets/tv_content.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/category_tab_bar.dart';
import 'package:tmdb/shared/widgets/poster_grid.dart';
import 'package:tmdb/shared/widgets/poster_grid_skeleton.dart';

import '../helpers/tv_fixtures.dart';

class _MockTvRepository extends Mock implements TvRepository {}

/// Wires real `TvListBloc` + `TvSearchBloc` with a mocked `TvRepository` and
/// pumps `TvContent` end-to-end.
///
/// Shows use `posterPath: null` so `PosterImage` shows its placeholder instead
/// of attempting network image loads inside the test.
void main() {
  late _MockTvRepository repo;

  setUp(() {
    repo = _MockTvRepository();
  });

  Future<void> pumpTv(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TvListBloc>(
              create: (_) => TvListBloc(repository: repo),
            ),
            BlocProvider<TvSearchBloc>(
              create: (_) => TvSearchBloc(repository: repo),
            ),
          ],
          child: const Scaffold(body: TvContent()),
        ),
      ),
    );
  }

  testWidgets('shows the skeleton then renders the loaded shows grid', (
    tester,
  ) async {
    when(
      () => repo.getTvShows(category: TvCategory.popular, page: 1),
    ).thenAnswer(
      (_) async => Right(
        buildPaginatedTv(
          totalPages: 1,
          shows: [
            buildTvShow(id: 1, name: 'Severance', posterPath: null),
            buildTvShow(id: 2, name: 'Andor', posterPath: null),
          ],
        ),
      ),
    );

    await pumpTv(tester);

    expect(find.byType(PosterGridSkeleton), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(PosterGridSkeleton), findsNothing);
    expect(find.byType(PosterGrid), findsOneWidget);
    expect(find.text('Severance'), findsOneWidget);
    expect(find.text('Andor'), findsOneWidget);
  });

  testWidgets('shows the error view with a Retry that re-fetches', (
    tester,
  ) async {
    when(
      () => repo.getTvShows(category: TvCategory.popular, page: 1),
    ).thenAnswer((_) async => const Left(NetworkFailure(message: 'offline')));

    await pumpTv(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    when(
      () => repo.getTvShows(category: TvCategory.popular, page: 1),
    ).thenAnswer(
      (_) async => Right(
        buildPaginatedTv(
          totalPages: 1,
          shows: [buildTvShow(id: 1, name: 'Recovered', posterPath: null)],
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsNothing);
    expect(find.text('Recovered'), findsOneWidget);
  });

  testWidgets('tapping a category tab triggers a refetch for that category', (
    tester,
  ) async {
    when(
      () => repo.getTvShows(category: TvCategory.popular, page: 1),
    ).thenAnswer(
      (_) async => Right(
        buildPaginatedTv(
          totalPages: 1,
          shows: [buildTvShow(id: 1, name: 'Popular Show', posterPath: null)],
        ),
      ),
    );
    when(
      () => repo.getTvShows(category: TvCategory.topRated, page: 1),
    ).thenAnswer(
      (_) async => Right(
        buildPaginatedTv(
          totalPages: 1,
          shows: [buildTvShow(id: 2, name: 'Top Show', posterPath: null)],
        ),
      ),
    );

    await pumpTv(tester);
    await tester.pumpAndSettle();
    expect(find.text('Popular Show'), findsOneWidget);

    expect(find.byType(CategoryTabBar), findsOneWidget);
    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();

    verify(
      () => repo.getTvShows(category: TvCategory.topRated, page: 1),
    ).called(1);
    expect(find.text('Top Show'), findsOneWidget);
    expect(find.text('Popular Show'), findsNothing);
  });

  testWidgets('typing in search hides the tabs and renders search results', (
    tester,
  ) async {
    when(
      () => repo.getTvShows(category: TvCategory.popular, page: 1),
    ).thenAnswer(
      (_) async => Right(
        buildPaginatedTv(
          totalPages: 1,
          shows: [buildTvShow(id: 1, name: 'Initial', posterPath: null)],
        ),
      ),
    );
    when(() => repo.searchTvShows(query: 'thrones', page: 1)).thenAnswer(
      (_) async => Right(
        buildPaginatedTv(
          totalPages: 1,
          shows: [
            buildTvShow(id: 1399, name: 'Game of Thrones', posterPath: null),
          ],
        ),
      ),
    );

    await pumpTv(tester);
    await tester.pumpAndSettle();
    expect(find.byType(CategoryTabBar), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'thrones');
    // The TvContent debounces search by 400ms; advance past it.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    verify(() => repo.searchTvShows(query: 'thrones', page: 1)).called(1);
    expect(find.byType(CategoryTabBar), findsNothing);
    expect(find.text('Game of Thrones'), findsOneWidget);
  });

  testWidgets('an empty search result shows the no-matches empty view', (
    tester,
  ) async {
    when(
      () => repo.getTvShows(category: TvCategory.popular, page: 1),
    ).thenAnswer((_) async => Right(buildPaginatedTv(shows: const [])));
    when(
      () => repo.searchTvShows(query: 'xyz', page: 1),
    ).thenAnswer((_) async => Right(buildPaginatedTv(shows: const [])));

    await pumpTv(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyView), findsOneWidget);
    expect(find.text('No matches for "xyz"'), findsOneWidget);
  });
}
