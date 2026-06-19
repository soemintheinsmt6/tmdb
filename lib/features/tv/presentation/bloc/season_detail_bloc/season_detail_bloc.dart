import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

import 'season_detail_event.dart';
import 'season_detail_state.dart';

class SeasonDetailBloc extends Bloc<SeasonDetailEvent, SeasonDetailState> {
  SeasonDetailBloc({required TvRepository repository})
    : _repository = repository,
      super(const SeasonDetailInitial()) {
    on<SeasonDetailFetched>(_onFetched);
  }

  final TvRepository _repository;

  Future<void> _onFetched(
    SeasonDetailFetched event,
    Emitter<SeasonDetailState> emit,
  ) async {
    emit(const SeasonDetailLoading());
    final result = await _repository.getSeasonDetail(
      event.tvShowId,
      event.seasonNumber,
    );
    result.fold(
      (failure) => emit(SeasonDetailError(message: failure.message)),
      (detail) => emit(SeasonDetailLoaded(detail: detail)),
    );
  }
}
