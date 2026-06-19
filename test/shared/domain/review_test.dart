import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/shared/domain/media/review.dart';

void main() {
  group('Review.fromJson', () {
    test('parses a review with nested author_details', () {
      final review = Review.fromJson(const <String, dynamic>{
        'id': '60d',
        'author': 'Roger Ebert',
        'author_details': {
          'username': 'rebert',
          'avatar_path': '/avatar.jpg',
          'rating': 8.0,
        },
        'content': 'A taut thriller.',
        'created_at': '2021-06-23T12:00:00.000Z',
      });

      expect(review.id, '60d');
      expect(review.author, 'Roger Ebert');
      expect(review.username, 'rebert');
      expect(review.avatarPath, '/avatar.jpg');
      expect(review.rating, 8.0);
      expect(review.content, 'A taut thriller.');
      expect(review.createdAt, '2021-06-23T12:00:00.000Z');
    });

    test('falls back to username when author is blank', () {
      final review = Review.fromJson(const <String, dynamic>{
        'author': '   ',
        'author_details': {'username': 'ann'},
        'content': 'Nice.',
      });

      expect(review.author, 'ann');
    });

    test('defaults missing fields gracefully', () {
      final review = Review.fromJson(const <String, dynamic>{'content': 'Hi'});

      expect(review.id, '');
      expect(review.author, '');
      expect(review.username, '');
      expect(review.avatarPath, isNull);
      expect(review.rating, isNull);
      expect(review.createdAt, '');
    });
  });

  group('Review computed properties', () {
    test('avatarUrl strips the stray leading slash on Gravatar URLs', () {
      final review = _review(
        avatarPath: '/https://secure.gravatar.com/avatar/abc.jpg',
      );

      expect(review.avatarUrl, 'https://secure.gravatar.com/avatar/abc.jpg');
    });

    test('avatarUrl builds a TMDB url for a plain image path', () {
      final review = _review(avatarPath: '/abc.jpg');

      expect(review.avatarUrl, contains('/abc.jpg'));
      expect(review.avatarUrl, startsWith('https://image.tmdb.org'));
    });

    test('avatarUrl is empty when there is no avatar', () {
      expect(_review(avatarPath: null).avatarUrl, '');
    });

    test('formattedRating is one decimal, or empty when unrated', () {
      expect(_review(rating: 7.456).formattedRating, '7.5');
      expect(_review(rating: null).formattedRating, '');
    });

    test('year extracts the leading year from createdAt', () {
      expect(_review(createdAt: '2021-06-23T12:00:00.000Z').year, '2021');
      expect(_review(createdAt: '').year, isNull);
    });

    test('initial is the uppercase first letter, or "?" when empty', () {
      expect(_review(author: 'bob').initial, 'B');
      expect(_review(author: '').initial, '?');
    });
  });
}

Review _review({
  String id = 'r1',
  String author = 'Ann',
  String username = 'ann',
  String? avatarPath,
  double? rating,
  String content = 'Body',
  String createdAt = '2021-01-01T00:00:00.000Z',
}) {
  return Review(
    id: id,
    author: author,
    username: username,
    avatarPath: avatarPath,
    rating: rating,
    content: content,
    createdAt: createdAt,
  );
}
