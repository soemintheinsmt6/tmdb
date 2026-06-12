import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';

/// Full person detail entity — combines `/person/{id}` with the person's
/// `combined_credits` filmography into a single domain object. Credits come
/// from a separate endpoint, so the repository injects them after the parallel
/// fetch (mirrors `MovieDetail`).
class Person extends Equatable {
  const Person({
    required this.id,
    required this.name,
    required this.biography,
    required this.birthday,
    required this.deathday,
    required this.placeOfBirth,
    required this.profilePath,
    required this.knownForDepartment,
    required this.filmography,
  });

  factory Person.fromJson(
    Map<String, dynamic> json, {
    List<PersonCredit> filmography = const [],
  }) {
    return Person(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      biography: json['biography'] as String? ?? '',
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String? ?? '',
      filmography: filmography,
    );
  }

  Person copyWith({List<PersonCredit>? filmography}) {
    return Person(
      id: id,
      name: name,
      biography: biography,
      birthday: birthday,
      deathday: deathday,
      placeOfBirth: placeOfBirth,
      profilePath: profilePath,
      knownForDepartment: knownForDepartment,
      filmography: filmography ?? this.filmography,
    );
  }

  final int id;
  final String name;
  final String biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String? profilePath;
  final String knownForDepartment;
  final List<PersonCredit> filmography;

  String profileUrl({String size = 'h632'}) =>
      ApiConstants.profileUrl(profilePath, size: size);

  /// Whole-year age — computed at [deathday] when the person has died,
  /// otherwise at the current date. `null` when [birthday] is missing or
  /// unparseable.
  int? get age {
    final born = DateTime.tryParse(birthday ?? '');
    if (born == null) return null;
    final end = DateTime.tryParse(deathday ?? '') ?? DateTime.now();
    var years = end.year - born.year;
    if (end.month < born.month ||
        (end.month == born.month && end.day < born.day)) {
      years--;
    }
    return years < 0 ? null : years;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    biography,
    birthday,
    deathday,
    placeOfBirth,
    profilePath,
    knownForDepartment,
    filmography,
  ];
}
