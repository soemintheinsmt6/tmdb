import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/domain/entities/movie_collection.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {
  const CollectionInitial();
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionLoaded extends CollectionState {
  const CollectionLoaded({required this.collection});
  final MovieCollection collection;

  @override
  List<Object?> get props => [collection];
}

class CollectionError extends CollectionState {
  const CollectionError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
