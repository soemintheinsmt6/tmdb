import 'package:tmdb/features/people/domain/entities/person.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';

/// Reusable builders. Every parameter has a sensible default so tests only
/// override the fields that matter to the assertion.
PersonCredit buildPersonCredit({
  int id = 100,
  String title = 'Fight Club',
  String? posterPath = '/poster.jpg',
  String releaseDate = '1999-10-15',
  double voteAverage = 8.4,
  int voteCount = 27000,
  String role = 'Tyler Durden',
  double popularity = 50.0,
  CreditMediaType? mediaType = CreditMediaType.movie,
}) {
  return PersonCredit(
    id: id,
    title: title,
    posterPath: posterPath,
    releaseDate: releaseDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    role: role,
    popularity: popularity,
    mediaType: mediaType,
  );
}

Person buildPerson({
  int id = 287,
  String name = 'Brad Pitt',
  String biography = 'An American actor and film producer.',
  String? birthday = '1963-12-18',
  String? deathday,
  String? placeOfBirth = 'Shawnee, Oklahoma, USA',
  String? profilePath = '/profile.jpg',
  String knownForDepartment = 'Acting',
  List<PersonCredit>? filmography,
}) {
  return Person(
    id: id,
    name: name,
    biography: biography,
    birthday: birthday,
    deathday: deathday,
    placeOfBirth: placeOfBirth,
    profilePath: profilePath,
    knownForDepartment: knownForDepartment,
    filmography: filmography ?? const [],
  );
}
