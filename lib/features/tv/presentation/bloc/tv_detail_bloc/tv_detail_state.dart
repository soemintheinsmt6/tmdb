import 'package:equatable/equatable.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';

abstract class TvDetailState extends Equatable {
  const TvDetailState();

  @override
  List<Object?> get props => [];
}

class TvDetailInitial extends TvDetailState {
  const TvDetailInitial();
}

class TvDetailLoading extends TvDetailState {
  const TvDetailLoading();
}

class TvDetailLoaded extends TvDetailState {
  const TvDetailLoaded({required this.detail});
  final TvShowDetail detail;

  @override
  List<Object?> get props => [detail];
}

class TvDetailError extends TvDetailState {
  const TvDetailError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
