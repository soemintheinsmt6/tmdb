import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit(this._repository)
    : super(FavouritesState.fromMovies(_repository.getAll())) {
    _subscription = _repository
        .watchAll()
        .map(FavouritesState.fromMovies)
        .listen(emit);
  }

  final FavouritesRepository _repository;
  late final StreamSubscription<FavouritesState> _subscription;

  void toggle(Movie movie) => _repository.toggle(movie);

  void remove(int movieId) => _repository.remove(movieId);

  void clear() => _repository.clear();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
