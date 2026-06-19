import 'package:equatable/equatable.dart';

abstract class SeasonDetailEvent extends Equatable {
  const SeasonDetailEvent();

  @override
  List<Object?> get props => [];
}

class SeasonDetailFetched extends SeasonDetailEvent {
  const SeasonDetailFetched({
    required this.tvShowId,
    required this.seasonNumber,
  });

  final int tvShowId;
  final int seasonNumber;

  @override
  List<Object?> get props => [tvShowId, seasonNumber];
}
