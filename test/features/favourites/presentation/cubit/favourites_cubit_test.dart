import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockFavouritesRepository extends Mock implements FavouritesRepository {}

void main() {
  late _MockFavouritesRepository repository;
  late StreamController<List<Movie>> controller;

  setUp(() {
    repository = _MockFavouritesRepository();
    controller = StreamController<List<Movie>>.broadcast();
    when(() => repository.watchAll()).thenAnswer((_) => controller.stream);
  });

  tearDown(() async {
    await controller.close();
  });

  test('seeds initial state from repository.getAll()', () {
    when(() => repository.getAll()).thenReturn([buildMovie(id: 1)]);

    final cubit = FavouritesCubit(repository);
    addTearDown(cubit.close);

    expect(cubit.state.ids, {1});
    expect(cubit.state.movies, hasLength(1));
  });

  test('emits a new state every time the repo stream pushes', () async {
    when(() => repository.getAll()).thenReturn(const []);

    final cubit = FavouritesCubit(repository);
    addTearDown(cubit.close);

    final emitted = <FavouritesState>[];
    final sub = cubit.stream.listen(emitted.add);
    addTearDown(sub.cancel);

    controller.add([buildMovie(id: 1)]);
    controller.add([buildMovie(id: 1), buildMovie(id: 2)]);
    await Future<void>.delayed(Duration.zero);

    expect(emitted, hasLength(2));
    expect(emitted[0].ids, {1});
    expect(emitted[1].ids, {1, 2});
  });

  test('toggle / remove / clear forward to the repository', () {
    when(() => repository.getAll()).thenReturn(const []);
    final cubit = FavouritesCubit(repository);
    addTearDown(cubit.close);

    final movie = buildMovie(id: 99);
    cubit.toggle(movie);
    cubit.remove(99);
    cubit.clear();

    verify(() => repository.toggle(movie)).called(1);
    verify(() => repository.remove(99)).called(1);
    verify(() => repository.clear()).called(1);
  });

  test('close cancels the stream subscription', () async {
    when(() => repository.getAll()).thenReturn(const []);
    final cubit = FavouritesCubit(repository);

    await cubit.close();

    // After close, additional stream pushes must not throw or alter state.
    expect(() => controller.add([buildMovie()]), returnsNormally);
  });
}
