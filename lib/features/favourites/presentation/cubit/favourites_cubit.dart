import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/favourites/data/repositories/favourites_repository.dart';
import 'package:tmdb/features/movies/data/models/movie.dart';

class FavouritesCubit extends Cubit<List<FavouriteMovie>> {
  FavouritesCubit(this._repository) : super(_repository.getAll()) {
    _subscription = _repository.watchAll().listen(emit);
  }

  final FavouritesRepository _repository;
  late final StreamSubscription<List<FavouriteMovie>> _subscription;

  bool isFavourite(int movieId) => _repository.isFavourite(movieId);

  bool toggle(Movie movie) => _repository.toggle(movie);

  void remove(int movieId) => _repository.removeByMovieId(movieId);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
