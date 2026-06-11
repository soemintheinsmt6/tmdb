import 'package:equatable/equatable.dart';

abstract class TvDetailEvent extends Equatable {
  const TvDetailEvent();

  @override
  List<Object?> get props => [];
}

class TvDetailFetched extends TvDetailEvent {
  const TvDetailFetched(this.tvShowId);
  final int tvShowId;

  @override
  List<Object?> get props => [tvShowId];
}
