import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';

/// Cast row from `/movie/{id}/credits`.
class CastMember extends Equatable {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
      order: (json['order'] as int?) ?? 0,
    );
  }

  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  String profileUrl({String size = 'w185'}) =>
      ApiConstants.profileUrl(profilePath, size: size);

  @override
  List<Object?> get props => [id, name, character, profilePath, order];
}
