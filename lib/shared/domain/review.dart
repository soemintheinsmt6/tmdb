import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/string_year.dart';

/// A user review for a movie or TV show. The `/reviews` payload has the same
/// shape for both `/movie/{id}/reviews` and `/tv/{id}/reviews`. Shared by the
/// movie and TV features.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.author,
    required this.username,
    required this.avatarPath,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  /// Parses a `/reviews` result row. Author metadata is nested under
  /// `author_details`; the top-level `author` is the display name.
  factory Review.fromJson(Map<String, dynamic> json) {
    final details =
        (json['author_details'] as Map<String, dynamic>?) ?? const {};
    final username = details['username'] as String? ?? '';
    return Review(
      id: json['id'] as String? ?? '',
      author: (json['author'] as String?)?.trim().isNotEmpty == true
          ? json['author'] as String
          : username,
      username: username,
      avatarPath: details['avatar_path'] as String?,
      rating: (details['rating'] as num?)?.toDouble(),
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  final String id;

  /// Display name; falls back to [username] when absent.
  final String author;
  final String username;
  final String? avatarPath;

  /// Author's score out of 10, or `null` when they didn't rate.
  final double? rating;
  final String content;

  /// ISO-8601 timestamp; `""` when unknown.
  final String createdAt;

  /// Avatar image URL. TMDB stores Gravatar avatars as an absolute URL with a
  /// stray leading slash (e.g. `/https://secure.gravatar.com/...`) — strip it.
  /// Anything else is a regular TMDB image path.
  String get avatarUrl {
    final path = avatarPath;
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('/http')) return path.substring(1);
    return ApiConstants.profileUrl(path);
  }

  /// One-decimal rating string (e.g. `"8.0"`) or `""` when unrated.
  String get formattedRating => rating == null ? '' : rating!.rating;

  /// Four-digit review year, or `null` when unknown.
  String? get year => createdAt.year;

  /// Uppercase first letter of the author, for the avatar fallback.
  String get initial => author.isNotEmpty ? author[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [
    id,
    author,
    username,
    avatarPath,
    rating,
    content,
    createdAt,
  ];
}
