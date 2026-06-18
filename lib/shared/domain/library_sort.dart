import 'package:tmdb/shared/domain/sortable_saved_item.dart';

/// Sort orders offered for the Library lists (favourites + watchlist).
enum LibrarySort {
  recentlyAdded('Recently added'),
  title('Title (A–Z)'),
  topRated('Top rated'),
  releaseDate('Release date');

  const LibrarySort(this.label);

  /// Human-readable label shown in the sort sheet.
  final String label;

  /// Comparator applied to a saved-item list. Parameter contravariance lets a
  /// `Comparator<SortableSavedItem>` sort a `List<FavouriteItem>` /
  /// `List<WatchlistItem>` directly.
  Comparator<SortableSavedItem> get comparator {
    switch (this) {
      case LibrarySort.recentlyAdded:
        return (a, b) => b.savedAt.compareTo(a.savedAt);
      case LibrarySort.title:
        return (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case LibrarySort.topRated:
        return (a, b) => b.voteAverage.compareTo(a.voteAverage);
      case LibrarySort.releaseDate:
        // Lexical compare works on `YYYY-MM-DD`; empty dates sort last.
        return (a, b) => b.date.compareTo(a.date);
    }
  }
}
