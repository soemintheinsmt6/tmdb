import 'package:equatable/equatable.dart';
import 'package:tmdb/features/tv/domain/entities/season_detail.dart';

abstract class SeasonDetailState extends Equatable {
  const SeasonDetailState();

  @override
  List<Object?> get props => [];
}

class SeasonDetailInitial extends SeasonDetailState {
  const SeasonDetailInitial();
}

class SeasonDetailLoading extends SeasonDetailState {
  const SeasonDetailLoading();
}

class SeasonDetailLoaded extends SeasonDetailState {
  const SeasonDetailLoaded({required this.detail});
  final SeasonDetail detail;

  @override
  List<Object?> get props => [detail];
}

class SeasonDetailError extends SeasonDetailState {
  const SeasonDetailError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
