import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/screens/favourite_screen.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourite_hero_card.dart';
import 'package:tmdb/shared/widgets/common/app_empty_view.dart';

import '../helpers/movie_fixtures.dart';
import '../helpers/tv_fixtures.dart';

class _MockFavouritesRepository extends Mock implements FavouritesRepository {}

/// Wires the real `FavouritesCubit` against a mocked repository — the cubit
/// seeds from `getAll()` and listens to a controllable `watchAll()` stream.
void main() {
  late _MockFavouritesRepository repo;
  late StreamController<List<FavouriteItem>> stream;

  setUpAll(() {
    registerFallbackValue(MediaType.movie);
  });

  setUp(() {
    repo = _MockFavouritesRepository();
    stream = StreamController<List<FavouriteItem>>.broadcast();
    when(() => repo.watchAll()).thenAnswer((_) => stream.stream);
  });

  tearDown(() async {
    await stream.close();
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FavouritesCubit>(
          create: (_) => FavouritesCubit(repo),
          child: const FavouriteScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the empty view when there are no favourites', (
    tester,
  ) async {
    when(() => repo.getAll()).thenReturn(const []);

    await pumpScreen(tester);
    await tester.pump();

    expect(find.byType(AppEmptyView), findsOneWidget);
    expect(find.text('No favourites yet'), findsOneWidget);
    expect(find.byType(FavouriteHeroCard), findsNothing);
  });

  testWidgets('renders a hero card per favourited movie and TV show', (
    tester,
  ) async {
    when(() => repo.getAll()).thenReturn([
      FavouriteItem.fromMovie(
        buildMovie(
          id: 1,
          title: 'Inception',
          posterPath: null,
          backdropPath: null,
        ),
      ),
      FavouriteItem.fromTvShow(
        buildTvShow(
          id: 2,
          name: 'The Wire',
          posterPath: null,
          backdropPath: null,
        ),
      ),
    ]);

    await pumpScreen(tester);
    await tester.pump();

    expect(find.byType(AppEmptyView), findsNothing);
    expect(find.byType(FavouriteHeroCard), findsNWidgets(2));
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('The Wire'), findsOneWidget);
  });

  testWidgets('reactively re-renders when the repo stream emits', (
    tester,
  ) async {
    when(() => repo.getAll()).thenReturn(const []);

    await pumpScreen(tester);
    await tester.pump();
    expect(find.byType(AppEmptyView), findsOneWidget);

    stream.add([
      FavouriteItem.fromMovie(
        buildMovie(
          id: 99,
          title: 'Late Arrival',
          posterPath: null,
          backdropPath: null,
        ),
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyView), findsNothing);
    expect(find.text('Late Arrival'), findsOneWidget);
  });

  testWidgets('tapping the remove button forwards to repository.remove', (
    tester,
  ) async {
    when(() => repo.getAll()).thenReturn([
      FavouriteItem.fromMovie(
        buildMovie(
          id: 42,
          title: 'To Remove',
          posterPath: null,
          backdropPath: null,
        ),
      ),
    ]);
    when(() => repo.remove(any(), any())).thenAnswer((_) async {});

    await pumpScreen(tester);
    await tester.pump();

    await tester.tap(find.byTooltip('Remove from favourites'));
    await tester.pump();

    verify(() => repo.remove(MediaType.movie, 42)).called(1);
  });
}
