import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/collection_bloc/collection_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/collection_bloc/collection_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/collection_bloc/collection_state.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late _MockMovieRepository repository;

  setUp(() {
    repository = _MockMovieRepository();
  });

  group('CollectionFetched', () {
    blocTest<CollectionBloc, CollectionState>(
      'emits Loading then Loaded on success',
      setUp: () {
        when(
          () => repository.getCollection(2344),
        ).thenAnswer((_) async => Right(buildMovieCollection()));
      },
      build: () => CollectionBloc(repository: repository),
      act: (bloc) => bloc.add(const CollectionFetched(2344)),
      expect: () => [
        const CollectionLoading(),
        isA<CollectionLoaded>()
            .having((s) => s.collection.id, 'collection.id', 2344)
            .having((s) => s.collection.parts, 'parts', isNotEmpty),
      ],
      verify: (_) => verify(() => repository.getCollection(2344)).called(1),
    );

    blocTest<CollectionBloc, CollectionState>(
      'emits Loading then Error on failure',
      setUp: () {
        when(() => repository.getCollection(1)).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'offline')),
        );
      },
      build: () => CollectionBloc(repository: repository),
      act: (bloc) => bloc.add(const CollectionFetched(1)),
      expect: () => const [
        CollectionLoading(),
        CollectionError(message: 'offline'),
      ],
    );
  });
}
