import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';
import 'package:tmdb/features/people/domain/repositories/person_repository.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_bloc.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_event.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_state.dart';

import '../../../../helpers/people_fixtures.dart';

class _MockPersonRepository extends Mock implements PersonRepository {}

void main() {
  late _MockPersonRepository repository;

  setUp(() {
    repository = _MockPersonRepository();
  });

  blocTest<PersonDetailBloc, PersonDetailState>(
    'emits Loading then Loaded on a successful fetch',
    setUp: () {
      when(
        () => repository.getPersonDetail(287),
      ).thenAnswer((_) async => Right<Failure, Person>(buildPerson()));
    },
    build: () => PersonDetailBloc(repository: repository),
    act: (bloc) => bloc.add(const PersonDetailFetched(287)),
    expect: () => [
      const PersonDetailLoading(),
      PersonDetailLoaded(person: buildPerson()),
    ],
  );

  blocTest<PersonDetailBloc, PersonDetailState>(
    'emits Loading then Error when the repo returns a Failure',
    setUp: () {
      when(() => repository.getPersonDetail(any())).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'no internet')),
      );
    },
    build: () => PersonDetailBloc(repository: repository),
    act: (bloc) => bloc.add(const PersonDetailFetched(1)),
    expect: () => const [
      PersonDetailLoading(),
      PersonDetailError(message: 'no internet'),
    ],
  );
}
