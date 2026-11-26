import 'package:equatable/equatable.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

/// One page of mixed movie + TV trending titles (people omitted).
class PaginatedTrending extends Equatable {
  const PaginatedTrending({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  final List<PosterItem> items;
  final int page;
  final int totalPages;

  @override
  List<Object?> get props => [items, page, totalPages];
}
