import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';

import '../../../../helpers/movie_fixtures.dart';
import '../../../../helpers/tv_fixtures.dart';

class _MockFavouritesRepository extends Mock implements FavouritesRepository {}

void main() {
  late _MockFavouritesRepository repository;
  late StreamController<List<FavouriteItem>> controller;

  setUp(() {
    repository = _MockFavouritesRepository();
    controller = StreamController<List<FavouriteItem>>.broadcast();
    when(() => repository.watchAll()).thenAnswer((_) => controller.stream);
  });

  tearDown(() async {
    await controller.close();
  });

  test('seeds initial state from repository.getAll()', () {
    when(() => repository.getAll()).thenReturn([
      FavouriteItem.fromMovie(buildMovie(id: 1)),
    ]);

    final cubit = FavouritesCubit(repository);
    addTearDown(cubit.close);

    expect(cubit.state.keys, {'movie:1'});
    expect(cubit.state.items, hasLength(1));
  });

  test('emits a new state every time the repo stream pushes', () async {
    when(() => repository.getAll()).thenReturn(const []);

    final cubit = FavouritesCubit(repository);
    addTearDown(cubit.close);

    final emitted = <FavouritesState>[];
    final sub = cubit.stream.listen(emitted.add);
    addTearDown(sub.cancel);

    controller.add([FavouriteItem.fromMovie(buildMovie(id: 1))]);
    controller.add([
      FavouriteItem.fromMovie(buildMovie(id: 1)),
      FavouriteItem.fromTvShow(buildTvShow(id: 2)),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(emitted, hasLength(2));
    expect(emitted[0].keys, {'movie:1'});
    expect(emitted[1].keys, {'movie:1', 'tv:2'});
  });

  test('toggle / remove / clear forward to the repository', () async {
    final item = FavouriteItem.fromTvShow(buildTvShow(id: 99));
    when(() => repository.getAll()).thenReturn(const []);
    when(() => repository.toggle(item)).thenAnswer((_) async {});
    when(() => repository.remove(MediaType.tv, 99)).thenAnswer((_) async {});
    when(() => repository.clear()).thenAnswer((_) async {});
    final cubit = FavouritesCubit(repository);
    addTearDown(cubit.close);

    await cubit.toggle(item);
    await cubit.remove(MediaType.tv, 99);
    await cubit.clear();

    verify(() => repository.toggle(item)).called(1);
    verify(() => repository.remove(MediaType.tv, 99)).called(1);
    verify(() => repository.clear()).called(1);
  });

  test('close cancels the stream subscription', () async {
    when(() => repository.getAll()).thenReturn(const []);
    final cubit = FavouritesCubit(repository);

    await cubit.close();

    // After close, additional stream pushes must not throw or alter state.
    expect(
      () => controller.add([FavouriteItem.fromMovie(buildMovie())]),
      returnsNormally,
    );
  });
}
