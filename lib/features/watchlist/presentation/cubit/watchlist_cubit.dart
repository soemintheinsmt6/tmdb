import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:tmdb/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_state.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit(this._repository)
    : super(WatchlistState.fromItems(_repository.getAll())) {
    _subscription = _repository
        .watchAll()
        .map(WatchlistState.fromItems)
        .listen(emit);
  }

  final WatchlistRepository _repository;
  late final StreamSubscription<WatchlistState> _subscription;

  Future<void> toggle(WatchlistItem item) => _repository.toggle(item);

  Future<void> remove(MediaType type, int id) => _repository.remove(type, id);

  Future<void> clear() => _repository.clear();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
