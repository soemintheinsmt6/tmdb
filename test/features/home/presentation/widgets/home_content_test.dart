import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/features/home/domain/entities/paginated_trending.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/home/presentation/bloc/home_bloc.dart';
import 'package:tmdb/features/home/presentation/bloc/home_event.dart';
import 'package:tmdb/features/home/presentation/bloc/home_state.dart';
import 'package:tmdb/features/home/presentation/screens/trending_screen.dart';
import 'package:tmdb/features/home/presentation/widgets/home_content.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';
import 'package:tmdb/shared/widgets/detail/detail_cards.dart';

import '../../../../helpers/movie_fixtures.dart' show buildMovie;
import '../../../../helpers/tv_fixtures.dart' show buildTvShow;

class _MockHomeBloc extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc {}

class _MockTrending extends Mock implements TrendingRepository {}

void main() {
  late _MockHomeBloc bloc;

  setUp(() => bloc = _MockHomeBloc());

  /// 8 trending titles: ids 1–6 fill the hero, 7 (movie) and 8 (tv) remain.
  final eight = <PosterItem>[
    for (var i = 1; i <= 7; i++) buildMovie(id: i),
    buildTvShow(id: 8),
  ];

  Future<void> pump(WidgetTester tester, HomeState state) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<HomeBloc>.value(
            value: bloc,
            child: const HomeContent(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Disposes the tree so the carousel's auto-advance timer is cancelled.
  Future<void> unmount(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  Finder railTitled(String title) =>
      find.byWidgetPredicate((w) => w is DetailPosterRail && w.title == title);

  testWidgets('Trending rail skips the titles already in the hero', (
    tester,
  ) async {
    await pump(
      tester,
      HomeState(
        status: HomeStatus.loaded,
        trending: eight,
        nowPlaying: [buildMovie(id: 10)],
      ),
    );

    final rail = tester.widget<DetailPosterRail>(railTitled('Trending'));
    // 8 trending − 6 in the hero → ids 7 and 8.
    expect(rail.items.map((e) => e.id), [7, 8]);

    await unmount(tester);
  });

  List<String> railTitles(WidgetTester tester) => tester
      .widgetList<DetailPosterRail>(find.byType(DetailPosterRail))
      .map((r) => r.title)
      .toList();

  testWidgets('For You comes first, then Trending', (tester) async {
    await pump(
      tester,
      HomeState(
        status: HomeStatus.loaded,
        trending: eight,
        forYou: [buildMovie(id: 30)],
        nowPlaying: [buildMovie(id: 10)],
      ),
    );

    // Only the rails inside the test viewport are built, so check the first two.
    expect(railTitles(tester).take(2), ['For You', 'Trending']);

    await unmount(tester);
  });

  testWidgets('Trending leads when For You is empty', (tester) async {
    await pump(
      tester,
      HomeState(
        status: HomeStatus.loaded,
        trending: eight,
        nowPlaying: [buildMovie(id: 10)],
      ),
    );

    expect(railTitles(tester).first, 'Trending');

    await unmount(tester);
  });

  testWidgets('hides the Trending rail when the hero holds every title', (
    tester,
  ) async {
    await pump(
      tester,
      HomeState(
        status: HomeStatus.loaded,
        trending: eight.take(6).toList(),
        nowPlaying: [buildMovie(id: 10)],
      ),
    );

    expect(railTitled('Trending'), findsNothing);
    expect(railTitled('Now Playing'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('Trending "See all" opens the trending grid', (tester) async {
    final repo = _MockTrending();
    when(() => repo.getTrendingPage(page: any(named: 'page'))).thenAnswer(
      (_) async =>
          const Right(PaginatedTrending(items: [], page: 1, totalPages: 1)),
    );
    sl.registerSingleton<TrendingRepository>(repo);
    addTearDown(() => sl.unregister<TrendingRepository>());

    await pump(tester, HomeState(status: HomeStatus.loaded, trending: eight));

    final seeAll = find.descendant(
      of: railTitled('Trending'),
      matching: find.text('See all'),
    );
    await tester.ensureVisible(seeAll);
    await tester.tap(seeAll);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(TrendingScreen), findsOneWidget);
    expect(find.text('Trending'), findsWidgets);

    await unmount(tester);
  });
}
