import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:tmdb/features/movies/presentation/widgets/category_tab_bar.dart';
import 'package:tmdb/features/movies/presentation/widgets/home_content.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_grid.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_list_skeleton.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';

import '../helpers/movie_fixtures.dart';

class _MockMovieRepository extends Mock implements MovieRepository {}

/// Wires real `MovieListBloc` + `MovieSearchBloc` with a mocked
/// `MovieRepository` and pumps `HomeContent` end-to-end.
///
/// Movies use `posterPath: null` so `MoviePoster` shows its placeholder
/// instead of attempting network image loads inside the test.
void main() {
  late _MockMovieRepository repo;

  setUp(() {
    repo = _MockMovieRepository();
  });

  Future<void> pumpHome(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<MovieListBloc>(
              create: (_) => MovieListBloc(repository: repo),
            ),
            BlocProvider<MovieSearchBloc>(
              create: (_) => MovieSearchBloc(repository: repo),
            ),
          ],
          child: const Scaffold(body: HomeContent()),
        ),
      ),
    );
  }

  testWidgets('shows the skeleton then renders the loaded movies grid',
      (tester) async {
    when(() => repo.getMovies(category: MovieCategory.popular, page: 1))
        .thenAnswer(
      (_) async => Right(
        buildPaginated(
          totalPages: 1,
          movies: [
            buildMovie(id: 1, title: 'Inception', posterPath: null),
            buildMovie(id: 2, title: 'Tenet', posterPath: null),
          ],
        ),
      ),
    );

    await pumpHome(tester);

    expect(find.byType(MovieListSkeleton), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(MovieListSkeleton), findsNothing);
    expect(find.byType(MovieGrid), findsOneWidget);
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Tenet'), findsOneWidget);
  });

  testWidgets('shows the error view with a Retry that re-fetches',
      (tester) async {
    when(() => repo.getMovies(category: MovieCategory.popular, page: 1))
        .thenAnswer(
      (_) async => const Left(NetworkFailure(message: 'offline')),
    );

    await pumpHome(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Subsequent fetch succeeds — tap Retry and verify the grid renders.
    when(() => repo.getMovies(category: MovieCategory.popular, page: 1))
        .thenAnswer(
      (_) async => Right(
        buildPaginated(
          totalPages: 1,
          movies: [buildMovie(id: 1, title: 'Recovered', posterPath: null)],
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsNothing);
    expect(find.text('Recovered'), findsOneWidget);
  });

  testWidgets('tapping a category tab triggers a refetch for that category',
      (tester) async {
    when(() => repo.getMovies(category: MovieCategory.popular, page: 1))
        .thenAnswer(
      (_) async => Right(
        buildPaginated(
          totalPages: 1,
          movies: [buildMovie(id: 1, title: 'Popular Movie', posterPath: null)],
        ),
      ),
    );
    when(() => repo.getMovies(category: MovieCategory.topRated, page: 1))
        .thenAnswer(
      (_) async => Right(
        buildPaginated(
          totalPages: 1,
          movies: [buildMovie(id: 2, title: 'Top Movie', posterPath: null)],
        ),
      ),
    );

    await pumpHome(tester);
    await tester.pumpAndSettle();
    expect(find.text('Popular Movie'), findsOneWidget);

    expect(find.byType(CategoryTabBar), findsOneWidget);
    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();

    verify(() =>
            repo.getMovies(category: MovieCategory.topRated, page: 1))
        .called(1);
    expect(find.text('Top Movie'), findsOneWidget);
    expect(find.text('Popular Movie'), findsNothing);
  });

  testWidgets('typing in search hides the tabs and renders search results',
      (tester) async {
    when(() => repo.getMovies(category: MovieCategory.popular, page: 1))
        .thenAnswer(
      (_) async => Right(
        buildPaginated(
          totalPages: 1,
          movies: [buildMovie(id: 1, title: 'Initial', posterPath: null)],
        ),
      ),
    );
    when(() => repo.searchMovies(query: 'inception', page: 1)).thenAnswer(
      (_) async => Right(
        buildPaginated(
          totalPages: 1,
          movies: [
            buildMovie(id: 27205, title: 'Inception', posterPath: null),
          ],
        ),
      ),
    );

    await pumpHome(tester);
    await tester.pumpAndSettle();
    expect(find.byType(CategoryTabBar), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'inception');
    // The HomeContent debounces search by 400ms; advance past it.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    verify(() => repo.searchMovies(query: 'inception', page: 1)).called(1);
    expect(find.byType(CategoryTabBar), findsNothing);
    expect(find.text('Inception'), findsOneWidget);
  });

  testWidgets('an empty search result shows the no-matches empty view',
      (tester) async {
    when(() => repo.getMovies(category: MovieCategory.popular, page: 1))
        .thenAnswer(
      (_) async => Right(buildPaginated(movies: const [])),
    );
    when(() => repo.searchMovies(query: 'xyz', page: 1)).thenAnswer(
      (_) async => Right(buildPaginated(movies: const [])),
    );

    await pumpHome(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyView), findsOneWidget);
    expect(find.text('No matches for "xyz"'), findsOneWidget);
  });
}
