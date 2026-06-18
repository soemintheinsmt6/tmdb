import 'package:hive/hive.dart';

import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';

/// Hive row for a favourited TV show. Mirrors `FavouriteMovie` for the TV
/// vertical; lives in its own box so numeric ids never collide with movies.
class FavouriteTvShow {
  FavouriteTvShow({
    required this.tvShowId,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.savedAt,
  });

  final int tvShowId;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String firstAirDate;
  final double voteAverage;
  final int voteCount;
  final DateTime savedAt;

  factory FavouriteTvShow.fromItem(FavouriteItem item) => FavouriteTvShow(
    tvShowId: item.id,
    name: item.title,
    overview: item.overview,
    posterPath: item.posterPath,
    backdropPath: item.backdropPath,
    firstAirDate: item.date,
    voteAverage: item.voteAverage,
    voteCount: item.voteCount,
    savedAt: item.savedAt,
  );

  /// Maps to the domain [FavouriteItem], preserving the stored [savedAt].
  FavouriteItem toFavouriteItem() => FavouriteItem(
    mediaType: MediaType.tv,
    id: tvShowId,
    title: name,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    date: firstAirDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    savedAt: savedAt,
  );
}

/// Hand-written [TypeAdapter] — keeps the project free of `build_runner`.
/// Type ids in use: `1` FavouriteMovie, `2` WatchlistEntry, `3` here.
class FavouriteTvShowAdapter extends TypeAdapter<FavouriteTvShow> {
  static const int kTypeId = 3;

  @override
  int get typeId => kTypeId;

  @override
  FavouriteTvShow read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldsCount; i++) reader.readByte(): reader.read(),
    };
    return FavouriteTvShow(
      tvShowId: fields[0] as int,
      name: fields[1] as String,
      overview: fields[2] as String,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      firstAirDate: fields[5] as String,
      voteAverage: fields[6] as double,
      voteCount: fields[7] as int,
      savedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavouriteTvShow obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.tvShowId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.overview)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.backdropPath)
      ..writeByte(5)
      ..write(obj.firstAirDate)
      ..writeByte(6)
      ..write(obj.voteAverage)
      ..writeByte(7)
      ..write(obj.voteCount)
      ..writeByte(8)
      ..write(obj.savedAt);
  }
}
