import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';

void main() {
  group('DiscoverFilter.toQuery', () {
    test('defaults to popularity sort with no facets', () {
      final query = const DiscoverFilter().toQuery();

      expect(query['sort_by'], 'popularity.desc');
      expect(query['include_adult'], 'false');
      expect(query.containsKey('with_genres'), isFalse);
      expect(query.containsKey('vote_average.gte'), isFalse);
      expect(query.containsKey('primary_release_year'), isFalse);
      expect(query.containsKey('vote_count.gte'), isFalse);
    });

    test('renders genres, rating, and year when set', () {
      const filter = DiscoverFilter(
        genreIds: {28, 12},
        sort: DiscoverSort.releaseDesc,
        minRating: 7,
        year: 2020,
      );

      final query = filter.toQuery();

      expect(query['sort_by'], 'primary_release_date.desc');
      expect(query['with_genres'], '28,12');
      expect(query['vote_average.gte'], '7.0');
      expect(query['primary_release_year'], '2020');
    });

    test('adds a vote-count floor only when sorting by rating', () {
      expect(
        const DiscoverFilter(sort: DiscoverSort.ratingDesc).toQuery(),
        containsPair('vote_count.gte', '200'),
      );
      expect(
        const DiscoverFilter(
          sort: DiscoverSort.popularityDesc,
        ).toQuery().containsKey('vote_count.gte'),
        isFalse,
      );
    });
  });

  group('DiscoverFilter.copyWith', () {
    test('overrides only the provided fields', () {
      const original = DiscoverFilter(genreIds: {1}, minRating: 5, year: 2000);

      final copy = original.copyWith(sort: DiscoverSort.ratingDesc);

      expect(copy.sort, DiscoverSort.ratingDesc);
      expect(copy.genreIds, {1});
      expect(copy.minRating, 5);
      expect(copy.year, 2000);
    });

    test('clearYear drops the year', () {
      const original = DiscoverFilter(year: 2000);

      expect(original.copyWith(clearYear: true).year, isNull);
    });
  });

  group('DiscoverFilter.isActive / activeCount', () {
    test('a default filter is inactive', () {
      expect(const DiscoverFilter().isActive, isFalse);
      expect(const DiscoverFilter().activeCount, 0);
    });

    test('counts each active facet', () {
      const filter = DiscoverFilter(
        genreIds: {1, 2},
        sort: DiscoverSort.ratingDesc,
        minRating: 6,
        year: 2021,
      );

      expect(filter.isActive, isTrue);
      expect(filter.activeCount, 4);
    });
  });
}
