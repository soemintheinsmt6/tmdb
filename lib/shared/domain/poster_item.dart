/// The minimal contract the poster widgets (`PosterCard`, `PosterGrid`,
/// `DetailPosterRail`) need to render any TMDB title — a movie or a TV show.
///
/// Feature entities implement this so the shared browse widgets stay decoupled
/// from any single feature's domain model.
abstract interface class PosterItem {
  int get id;

  /// Display title (`Movie.title` / `TvShow.name`).
  String get title;

  /// Four-digit release / first-air year, or `null` when unknown.
  String? get year;

  /// One-decimal score (e.g. `"7.5"`) or `"NR"` when unrated.
  String get formattedRating;

  /// Fully-qualified poster image URL, or `''` when there is no poster.
  String posterUrl({String size});
}
