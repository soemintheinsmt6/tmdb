import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit(this._repository)
    : super(FavouritesState.fromItems(_repository.getAll())) {
    _subscription = _repository
        .watchAll()
        .map(FavouritesState.fromItems)
        .listen(emit);
  }

  final FavouritesRepository _repository;
  late final StreamSubscription<FavouritesState> _subscription;

  Future<void> toggle(FavouriteItem item) => _repository.toggle(item);

  Future<void> remove(MediaType type, int id) => _repository.remove(type, id);

  Future<void> clear() => _repository.clear();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
