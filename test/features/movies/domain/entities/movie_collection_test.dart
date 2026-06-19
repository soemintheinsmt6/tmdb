import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/movies/domain/entities/movie_collection.dart';

void main() {
  group('MovieCollectionRef.tryFromJson', () {
    test('parses a belongs_to_collection object', () {
      final json = <String, dynamic>{
        'id': 2344,
        'name': 'The Matrix Collection',
        'poster_path': '/p.jpg',
        'backdrop_path': '/b.jpg',
      };
      final ref = MovieCollectionRef.tryFromJson(json);

      expect(ref, isNotNull);
      expect(ref!.id, 2344);
      expect(ref.name, 'The Matrix Collection');
      expect(ref.backdropUrl(), contains('/b.jpg'));
    });

    test('returns null when the field is absent or has no id', () {
      expect(MovieCollectionRef.tryFromJson(null), isNull);
      expect(
        MovieCollectionRef.tryFromJson(<String, dynamic>{'name': 'x'}),
        isNull,
      );
    });
  });

  group('MovieCollection.fromJson', () {
    test('parses parts and orders them by release date', () {
      final json = <String, dynamic>{
        'id': 2344,
        'name': 'The Matrix Collection',
        'overview': 'Simulated reality.',
        'backdrop_path': '/b.jpg',
        'parts': [
          {'id': 604, 'title': 'Reloaded', 'release_date': '2003-05-15'},
          {'id': 603, 'title': 'The Matrix', 'release_date': '1999-03-31'},
        ],
      };

      final collection = MovieCollection.fromJson(json);

      expect(collection.id, 2344);
      expect(collection.parts.map((m) => m.id), [603, 604]); // chronological
      expect(collection.parts.first.title, 'The Matrix');
    });

    test('tolerates a missing parts list', () {
      final json = <String, dynamic>{'id': 1, 'name': 'Lonely'};
      final collection = MovieCollection.fromJson(json);
      expect(collection.parts, isEmpty);
    });
  });
}
