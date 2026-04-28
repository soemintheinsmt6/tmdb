import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/data/models/movie_detail.dart';

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {
  const MovieDetailInitial();
}

class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

class MovieDetailLoaded extends MovieDetailState {
  const MovieDetailLoaded({required this.detail});
  final MovieDetail detail;

  @override
  List<Object?> get props => [detail];
}

class MovieDetailError extends MovieDetailState {
  const MovieDetailError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
