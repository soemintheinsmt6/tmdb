import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';

/// A single streaming / rental provider (e.g. Netflix) from `/watch/providers`.
class WatchProvider extends Equatable {
  const WatchProvider({
    required this.providerId,
    required this.name,
    required this.logoPath,
    required this.displayPriority,
  });

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerId: (json['provider_id'] as int?) ?? 0,
      name: json['provider_name'] as String? ?? '',
      logoPath: json['logo_path'] as String?,
      displayPriority: (json['display_priority'] as int?) ?? 0,
    );
  }

  final int providerId;
  final String name;
  final String? logoPath;

  /// TMDB's preferred ordering within a region (lower shows first).
  final int displayPriority;

  String logoUrl({String size = 'w92'}) {
    final path = logoPath;
    if (path == null || path.isEmpty) return '';
    return '${ApiConstants.imageBaseUrl}/$size$path';
  }

  @override
  List<Object?> get props => [providerId, name, logoPath, displayPriority];
}
