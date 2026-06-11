import 'package:equatable/equatable.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

abstract class TvListState extends Equatable {
  const TvListState({required this.category});
  final TvCategory category;

  @override
  List<Object?> get props => [category];
}

class TvListInitial extends TvListState {
  const TvListInitial({required super.category});
}

class TvListLoading extends TvListState {
  const TvListLoading({required super.category});
}

class TvListLoaded extends TvListState {
  const TvListLoaded({
    required super.category,
    required this.shows,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  final List<TvShow> shows;
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => page < totalPages;

  TvListLoaded copyWith({
    TvCategory? category,
    List<TvShow>? shows,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return TvListLoaded(
      category: category ?? this.category,
      shows: shows ?? this.shows,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [category, shows, page, totalPages, isLoadingMore];
}

class TvListError extends TvListState {
  const TvListError({required super.category, required this.message});
  final String message;

  @override
  List<Object?> get props => [category, message];
}
