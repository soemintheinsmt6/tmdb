/// The fields the library's sort orders depend on. Implemented by the saved
/// items of both the favourites and watchlist features, so one set of
/// comparators ([LibrarySort]) works across both without duplication.
abstract interface class SortableSavedItem {
  /// Display title.
  String get title;

  /// Community score, backing the "Top rated" order.
  double get voteAverage;

  /// Release / first-air date (`YYYY-MM-DD`), backing the "Release date" order.
  String get date;

  /// When the item was saved, backing the default "Recently added" order.
  DateTime get savedAt;
}
