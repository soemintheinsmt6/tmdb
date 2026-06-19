import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/features/tv/data/datasources/tv_remote_data_source.dart';
import 'package:tmdb/features/tv/data/repositories/tv_repository_impl.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/shared/domain/media_image.dart';
import 'package:tmdb/shared/domain/review.dart';
import 'package:tmdb/shared/domain/video.dart';

import '../../../../helpers/tv_fixtures.dart';
import '../../../../helpers/watch_provider_fixtures.dart';

class _MockRemote extends Mock implements TvRemoteDataSource {}

/// Captures the messages passed to the logging seam so tests can assert that
/// failures are observed rather than swallowed.
class _RecordingLogger implements AppLogger {
  final List<String> warnings = [];

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      warnings.add(message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

void main() {
  late _MockRemote remote;
  late TvRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = TvRepositoryImpl(remote);
    // Videos, reviews, images and watch providers joined the parallel detail
    // fetch; default every composition test so tests only stub what they assert.
    when(
      () => remote.getTvVideos(any()),
    ).thenAnswer((_) async => const <Video>[]);
    when(
      () => remote.getTvReviews(any()),
    ).thenAnswer((_) async => const <Review>[]);
    when(
      () => remote.getTvImages(any()),
    ).thenAnswer((_) async => const <MediaImage>[]);
    when(
      () => remote.getTvWatchProviders(any(), region: any(named: 'region')),
    ).thenAnswer((_) async => null);
  });

  group('getTvShows', () {
    test('returns Right(PaginatedTvShows) on success', () async {
      final paginated = buildPaginatedTv();
      when(
        () => remote.getTvShows(category: TvCategory.popular, page: 1),
      ).thenAnswer((_) async => paginated);

      final result = await repository.getTvShows(
        category: TvCategory.popular,
        page: 1,
      );

      expect(result, Right<Failure, PaginatedTvShows>(paginated));
      verify(
        () => remote.getTvShows(category: TvCategory.popular, page: 1),
      ).called(1);
    });
  });

  group('searchTvShows', () {
    test('forwards query and page to the remote', () async {
      final paginated = buildPaginatedTv();
      when(
        () => remote.searchTvShows(query: 'thrones', page: 2),
      ).thenAnswer((_) async => paginated);

      final result = await repository.searchTvShows(query: 'thrones', page: 2);

      expect(result, Right<Failure, PaginatedTvShows>(paginated));
      verify(() => remote.searchTvShows(query: 'thrones', page: 2)).called(1);
    });
  });

  group('getTvShowDetail composition', () {
    test(
      'fetches detail, credits, and recommendations in parallel and merges',
      () async {
        final detailBase = buildTvShowDetail();
        final cast = List.generate(
          25,
          (i) => buildTvCastMember(id: i, order: i),
        );
        final recs = buildPaginatedTv(
          shows: [buildTvShow(id: 100), buildTvShow(id: 101)],
        );
        final videos = [buildVideo(id: 'a'), buildVideo(id: 'b')];
        final reviews = List.generate(15, (i) => buildReview(id: 'r$i'));
        final images = List.generate(
          20,
          (i) => buildImage(filePath: '/img$i.jpg'),
        );

        when(
          () => remote.getTvShowDetail(1399),
        ).thenAnswer((_) async => detailBase);
        when(() => remote.getTvCredits(1399)).thenAnswer((_) async => cast);
        when(
          () => remote.getTvRecommendations(1399),
        ).thenAnswer((_) async => recs);
        when(() => remote.getTvVideos(1399)).thenAnswer((_) async => videos);
        when(() => remote.getTvReviews(1399)).thenAnswer((_) async => reviews);
        when(() => remote.getTvImages(1399)).thenAnswer((_) async => images);
        final watchProviders = buildWatchProviders();
        when(
          () => remote.getTvWatchProviders(1399, region: any(named: 'region')),
        ).thenAnswer((_) async => watchProviders);

        final result = await repository.getTvShowDetail(1399);

        final composed = result.getOrElse(() => throw 'expected Right');
        // Composition contract: cast capped at 20, recommendations.shows extracted.
        expect(composed.cast, hasLength(20));
        expect(composed.cast.first.id, 0);
        expect(composed.cast.last.id, 19);
        expect(composed.recommendations.map((s) => s.id), [100, 101]);
        expect(composed.videos.map((v) => v.id), ['a', 'b']);
        // Reviews capped at 10, images capped at 16.
        expect(composed.reviews, hasLength(10));
        expect(composed.reviews.first.id, 'r0');
        expect(composed.images, hasLength(16));
        expect(composed.images.first.filePath, '/img0.jpg');
        // Watch providers injected for the resolved region.
        expect(composed.watchProviders, watchProviders);
        // Base detail fields preserved via copyWith.
        expect(composed.id, detailBase.id);
        expect(composed.name, detailBase.name);
        expect(composed.numberOfSeasons, detailBase.numberOfSeasons);

        verify(() => remote.getTvShowDetail(1399)).called(1);
        verify(() => remote.getTvCredits(1399)).called(1);
        verify(() => remote.getTvRecommendations(1399)).called(1);
        verify(() => remote.getTvVideos(1399)).called(1);
        verify(() => remote.getTvReviews(1399)).called(1);
        verify(() => remote.getTvImages(1399)).called(1);
      },
    );

    test(
      'passes through cast unchanged when there are 20 or fewer members',
      () async {
        final cast = List.generate(
          8,
          (i) => buildTvCastMember(id: i, order: i),
        );

        when(
          () => remote.getTvShowDetail(1),
        ).thenAnswer((_) async => buildTvShowDetail());
        when(() => remote.getTvCredits(1)).thenAnswer((_) async => cast);
        when(
          () => remote.getTvRecommendations(1),
        ).thenAnswer((_) async => buildPaginatedTv(shows: const []));

        final result = await repository.getTvShowDetail(1);

        final composed = result.getOrElse(() => throw 'expected Right');
        expect(composed.cast, hasLength(8));
      },
    );
  });

  group('exception → Failure mapping', () {
    test('UnauthorizedException → ServerFailure(401)', () async {
      when(
        () => remote.getTvShows(category: TvCategory.popular, page: 1),
      ).thenThrow(const UnauthorizedException(message: 'bad token'));

      final result = await repository.getTvShows(category: TvCategory.popular);

      expect(
        result,
        const Left<Failure, PaginatedTvShows>(
          ServerFailure(message: 'bad token', statusCode: 401),
        ),
      );
    });

    test(
      'ServerException → ServerFailure with the original status code',
      () async {
        when(
          () => remote.searchTvShows(query: 'x', page: 1),
        ).thenThrow(const ServerException(message: 'boom', statusCode: 503));

        final result = await repository.searchTvShows(query: 'x');

        expect(
          result,
          const Left<Failure, PaginatedTvShows>(
            ServerFailure(message: 'boom', statusCode: 503),
          ),
        );
      },
    );

    test('NetworkException → NetworkFailure', () async {
      when(
        () => remote.getTvShowDetail(1),
      ).thenThrow(const NetworkException(message: 'offline'));

      final result = await repository.getTvShowDetail(1);

      expect(
        result,
        const Left<Failure, TvShowDetail>(NetworkFailure(message: 'offline')),
      );
    });

    test(
      'exception thrown anywhere in the parallel detail fetch is mapped',
      () async {
        when(
          () => remote.getTvShowDetail(1),
        ).thenAnswer((_) async => buildTvShowDetail());
        when(() => remote.getTvCredits(1)).thenThrow(
          const ServerException(message: 'credits failed', statusCode: 500),
        );
        when(
          () => remote.getTvRecommendations(1),
        ).thenAnswer((_) async => buildPaginatedTv());

        final result = await repository.getTvShowDetail(1);

        expect(
          result,
          const Left<Failure, TvShowDetail>(
            ServerFailure(message: 'credits failed', statusCode: 500),
          ),
        );
      },
    );

    test('a credits failure raised asynchronously is mapped to its original '
        'status (not wrapped in ParallelWaitError)', () async {
      when(
        () => remote.getTvShowDetail(1),
      ).thenAnswer((_) async => buildTvShowDetail());
      when(() => remote.getTvCredits(1)).thenAnswer(
        (_) async => throw const ServerException(
          message: 'credits failed',
          statusCode: 500,
        ),
      );
      when(
        () => remote.getTvRecommendations(1),
      ).thenAnswer((_) async => buildPaginatedTv());

      final result = await repository.getTvShowDetail(1);

      expect(
        result,
        const Left<Failure, TvShowDetail>(
          ServerFailure(message: 'credits failed', statusCode: 500),
        ),
      );
    });

    test('mapped failures are reported through the logging seam', () async {
      final logger = _RecordingLogger();
      final observed = TvRepositoryImpl(remote, logger: logger);
      when(
        () => remote.getTvShows(category: TvCategory.popular, page: 1),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 503));

      await observed.getTvShows(category: TvCategory.popular);

      expect(logger.warnings, hasLength(1));
      expect(logger.warnings.single, contains('503'));
    });
  });
}
