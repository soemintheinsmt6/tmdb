import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/season_detail_bloc/season_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/season_detail_bloc/season_detail_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/season_detail_bloc/season_detail_state.dart';

import '../../../../helpers/tv_fixtures.dart';

class _MockTvRepository extends Mock implements TvRepository {}

void main() {
  late _MockTvRepository repository;

  setUp(() {
    repository = _MockTvRepository();
  });

  group('SeasonDetailFetched', () {
    blocTest<SeasonDetailBloc, SeasonDetailState>(
      'emits Loading then Loaded on success',
      setUp: () {
        when(
          () => repository.getSeasonDetail(1399, 1),
        ).thenAnswer((_) async => Right(buildSeasonDetail()));
      },
      build: () => SeasonDetailBloc(repository: repository),
      act: (bloc) =>
          bloc.add(const SeasonDetailFetched(tvShowId: 1399, seasonNumber: 1)),
      expect: () => [
        const SeasonDetailLoading(),
        isA<SeasonDetailLoaded>()
            .having((s) => s.detail.seasonNumber, 'seasonNumber', 1)
            .having((s) => s.detail.episodes, 'episodes', isNotEmpty),
      ],
      verify: (_) =>
          verify(() => repository.getSeasonDetail(1399, 1)).called(1),
    );

    blocTest<SeasonDetailBloc, SeasonDetailState>(
      'emits Loading then Error on failure',
      setUp: () {
        when(() => repository.getSeasonDetail(1, 2)).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'offline')),
        );
      },
      build: () => SeasonDetailBloc(repository: repository),
      act: (bloc) =>
          bloc.add(const SeasonDetailFetched(tvShowId: 1, seasonNumber: 2)),
      expect: () => const [
        SeasonDetailLoading(),
        SeasonDetailError(message: 'offline'),
      ],
    );
  });
}
