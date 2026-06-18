import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourite_hero_card.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourites_list_view.dart';
import 'package:tmdb/shared/domain/library_view.dart';
import 'package:tmdb/shared/widgets/poster_card.dart';

import '../../../../helpers/movie_fixtures.dart';
import '../../../../helpers/tv_fixtures.dart';

class _MockFavouritesRepository extends Mock implements FavouritesRepository {}

void main() {
  late _MockFavouritesRepository repo;
  late StreamController<List<FavouriteItem>> stream;

  setUp(() {
    repo = _MockFavouritesRepository();
    stream = StreamController<List<FavouriteItem>>.broadcast();
    when(() => repo.watchAll()).thenAnswer((_) => stream.stream);
    when(() => repo.getAll()).thenReturn([
      FavouriteItem.fromMovie(buildMovie(id: 1)),
      FavouriteItem.fromTvShow(buildTvShow(id: 2)),
    ]);
  });

  tearDown(() async {
    await stream.close();
  });

  Future<void> pump(WidgetTester tester, LibraryView view) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FavouritesCubit>(
          create: (_) => FavouritesCubit(repo),
          child: Scaffold(body: FavouritesListView(view: view)),
        ),
      ),
    );
  }

  testWidgets('list view renders hero cards, no poster cards', (tester) async {
    await pump(tester, LibraryView.list);
    await tester.pump();

    expect(find.byType(FavouriteHeroCard), findsNWidgets(2));
    expect(find.byType(PosterCard), findsNothing);
  });

  testWidgets('grid view renders poster cards, no hero cards', (tester) async {
    await pump(tester, LibraryView.grid);
    await tester.pump();

    expect(find.byType(PosterCard), findsNWidgets(2));
    expect(find.byType(FavouriteHeroCard), findsNothing);
  });
}
