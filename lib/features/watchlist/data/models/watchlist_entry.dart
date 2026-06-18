import 'package:hive/hive.dart';

import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';

/// Hive row for a watchlist entry. Holds both movies and TV shows; the
/// [mediaTypeIndex] field maps to [MediaType.values].
class WatchlistEntry {
  WatchlistEntry({
    required this.mediaTypeIndex,
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.date,
    required this.voteAverage,
    required this.voteCount,
    required this.savedAt,
  });

  final int mediaTypeIndex;
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String date;
  final double voteAverage;
  final int voteCount;
  final DateTime savedAt;

  factory WatchlistEntry.fromItem(WatchlistItem item) => WatchlistEntry(
    mediaTypeIndex: item.mediaType.index,
    id: item.id,
    title: item.title,
    overview: item.overview,
    posterPath: item.posterPath,
    backdropPath: item.backdropPath,
    date: item.date,
    voteAverage: item.voteAverage,
    voteCount: item.voteCount,
    savedAt: item.savedAt,
  );

  WatchlistItem toItem() => WatchlistItem(
    mediaType: MediaType.values[mediaTypeIndex],
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    date: date,
    voteAverage: voteAverage,
    voteCount: voteCount,
    savedAt: savedAt,
  );
}

/// Hand-written [TypeAdapter] — keeps the project free of `build_runner`.
/// Bump [kTypeId] only on a breaking schema change (and migrate on read).
/// Favourites owns typeId `1`; the watchlist owns `2`.
class WatchlistEntryAdapter extends TypeAdapter<WatchlistEntry> {
  static const int kTypeId = 2;

  @override
  int get typeId => kTypeId;

  @override
  WatchlistEntry read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldsCount; i++) reader.readByte(): reader.read(),
    };
    return WatchlistEntry(
      mediaTypeIndex: fields[0] as int,
      id: fields[1] as int,
      title: fields[2] as String,
      overview: fields[3] as String,
      posterPath: fields[4] as String?,
      backdropPath: fields[5] as String?,
      date: fields[6] as String,
      voteAverage: fields[7] as double,
      voteCount: fields[8] as int,
      savedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.mediaTypeIndex)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.overview)
      ..writeByte(4)
      ..write(obj.posterPath)
      ..writeByte(5)
      ..write(obj.backdropPath)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.voteAverage)
      ..writeByte(8)
      ..write(obj.voteCount)
      ..writeByte(9)
      ..write(obj.savedAt);
  }
}
