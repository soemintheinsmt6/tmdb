import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/people/domain/repositories/person_repository.dart';

import 'person_detail_event.dart';
import 'person_detail_state.dart';

class PersonDetailBloc extends Bloc<PersonDetailEvent, PersonDetailState> {
  PersonDetailBloc({required PersonRepository repository})
    : _repository = repository,
      super(const PersonDetailInitial()) {
    on<PersonDetailFetched>(_onFetched);
  }

  final PersonRepository _repository;

  Future<void> _onFetched(
    PersonDetailFetched event,
    Emitter<PersonDetailState> emit,
  ) async {
    emit(const PersonDetailLoading());
    final result = await _repository.getPersonDetail(event.personId);
    result.fold(
      (failure) => emit(PersonDetailError(message: failure.message)),
      (person) => emit(PersonDetailLoaded(person: person)),
    );
  }
}
