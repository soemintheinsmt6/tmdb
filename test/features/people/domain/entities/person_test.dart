import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';

import '../../../../helpers/people_fixtures.dart';

void main() {
  group('Person.fromJson', () {
    test('parses the /person/{id} payload with an empty filmography', () {
      final person = Person.fromJson(const {
        'id': 287,
        'name': 'Brad Pitt',
        'biography': 'An American actor.',
        'birthday': '1963-12-18',
        'place_of_birth': 'Shawnee, Oklahoma, USA',
        'profile_path': '/p.jpg',
        'known_for_department': 'Acting',
      });

      expect(person.id, 287);
      expect(person.name, 'Brad Pitt');
      expect(person.knownForDepartment, 'Acting');
      expect(person.deathday, isNull);
      expect(person.filmography, isEmpty);
    });

    test('injects the filmography passed alongside the payload', () {
      final person = Person.fromJson(
        const {'id': 1, 'name': 'X'},
        filmography: [buildPersonCredit(id: 1), buildPersonCredit(id: 2)],
      );

      expect(person.filmography, hasLength(2));
    });
  });

  test('copyWith replaces only the filmography', () {
    final base = buildPerson();
    final updated = base.copyWith(filmography: [buildPersonCredit(id: 9)]);

    expect(updated.filmography.single.id, 9);
    expect(updated.name, base.name);
    expect(updated.birthday, base.birthday);
  });

  group('age', () {
    test('is computed at the deathday for a deceased person', () {
      final person = buildPerson(
        birthday: '1950-06-15',
        deathday: '2000-06-15',
      );
      expect(person.age, 50);
    });

    test('accounts for a birthday that has not occurred yet that year', () {
      final person = buildPerson(
        birthday: '1950-06-15',
        deathday: '2000-06-14',
      );
      expect(person.age, 49);
    });

    test('is null when the birthday is missing or unparseable', () {
      expect(buildPerson(birthday: null).age, isNull);
      expect(buildPerson(birthday: '').age, isNull);
    });
  });

  test('profileUrl is empty when there is no profile path', () {
    expect(buildPerson(profilePath: null).profileUrl(), '');
    expect(buildPerson(profilePath: '/p.jpg').profileUrl(), endsWith('/p.jpg'));
  });
}
