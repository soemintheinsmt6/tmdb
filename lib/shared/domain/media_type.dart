/// Whether a saved title is a movie or a TV show. Shared by the favourites and
/// watchlist features, which both span the two verticals.
///
/// Persisted by index in the Hive layer, so only ever append new values —
/// never reorder.
enum MediaType { movie, tv }
