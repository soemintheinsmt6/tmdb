import 'package:hive/hive.dart';

import 'package:tmdb/features/movies/domain/entities/movie.dart';

class FavouriteMovie {
  FavouriteMovie({
    required this.movieId,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.savedAt,
  });

  final int movieId;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final DateTime savedAt;

  factory FavouriteMovie.fromMovie(Movie m) => FavouriteMovie(
    movieId: m.id,
    title: m.title,
    overview: m.overview,
    posterPath: m.posterPath,
    backdropPath: m.backdropPath,
    releaseDate: m.releaseDate,
    voteAverage: m.voteAverage,
    voteCount: m.voteCount,
    savedAt: DateTime.now(),
  );

  Movie toMovie() => Movie(
    id: movieId,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    releaseDate: releaseDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    genreIds: const [],
  );
}

/// Hand-written [TypeAdapter] — keeps the project free of `build_runner`.
/// Bump [kTypeId] only on a breaking schema change (and migrate on read).
class FavouriteMovieAdapter extends TypeAdapter<FavouriteMovie> {
  static const int kTypeId = 1;

  @override
  int get typeId => kTypeId;

  @override
  FavouriteMovie read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldsCount; i++) reader.readByte(): reader.read(),
    };
    return FavouriteMovie(
      movieId: fields[0] as int,
      title: fields[1] as String,
      overview: fields[2] as String,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      releaseDate: fields[5] as String,
      voteAverage: fields[6] as double,
      voteCount: fields[7] as int,
      savedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavouriteMovie obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.movieId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.overview)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.backdropPath)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.voteAverage)
      ..writeByte(7)
      ..write(obj.voteCount)
      ..writeByte(8)
      ..write(obj.savedAt);
  }
}
