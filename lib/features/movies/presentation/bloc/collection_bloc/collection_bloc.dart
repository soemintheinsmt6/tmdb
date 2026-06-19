import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';

import 'collection_event.dart';
import 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  CollectionBloc({required MovieRepository repository})
    : _repository = repository,
      super(const CollectionInitial()) {
    on<CollectionFetched>(_onFetched);
  }

  final MovieRepository _repository;

  Future<void> _onFetched(
    CollectionFetched event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());
    final result = await _repository.getCollection(event.collectionId);
    result.fold(
      (failure) => emit(CollectionError(message: failure.message)),
      (collection) => emit(CollectionLoaded(collection: collection)),
    );
  }
}
