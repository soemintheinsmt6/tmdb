import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_state.dart';

import '../../../../helpers/tv_fixtures.dart';

class _MockTvRepository extends Mock implements TvRepository {}

void main() {
  late _MockTvRepository repository;

  setUp(() {
    repository = _MockTvRepository();
  });

  group('TvDetailFetched', () {
    blocTest<TvDetailBloc, TvDetailState>(
      'emits Loading then Loaded on success',
      setUp: () {
        when(
          () => repository.getTvShowDetail(1399),
        ).thenAnswer((_) async => Right(buildTvShowDetail()));
      },
      build: () => TvDetailBloc(repository: repository),
      act: (bloc) => bloc.add(const TvDetailFetched(1399)),
      expect: () => [
        const TvDetailLoading(),
        isA<TvDetailLoaded>().having((s) => s.detail.id, 'detail.id', 1399),
      ],
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'emits Loading then Error on failure',
      setUp: () {
        when(() => repository.getTvShowDetail(1)).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'offline')),
        );
      },
      build: () => TvDetailBloc(repository: repository),
      act: (bloc) => bloc.add(const TvDetailFetched(1)),
      expect: () => const [
        TvDetailLoading(),
        TvDetailError(message: 'offline'),
      ],
    );
  });
}
