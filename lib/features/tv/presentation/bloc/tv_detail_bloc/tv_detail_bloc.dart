import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

import 'tv_detail_event.dart';
import 'tv_detail_state.dart';

class TvDetailBloc extends Bloc<TvDetailEvent, TvDetailState> {
  TvDetailBloc({required TvRepository repository})
    : _repository = repository,
      super(const TvDetailInitial()) {
    on<TvDetailFetched>(_onFetched);
  }

  final TvRepository _repository;

  Future<void> _onFetched(
    TvDetailFetched event,
    Emitter<TvDetailState> emit,
  ) async {
    emit(const TvDetailLoading());
    final result = await _repository.getTvShowDetail(event.tvShowId);
    result.fold(
      (failure) => emit(TvDetailError(message: failure.message)),
      (detail) => emit(TvDetailLoaded(detail: detail)),
    );
  }
}
