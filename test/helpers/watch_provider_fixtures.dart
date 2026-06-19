import 'package:tmdb/shared/domain/media/watch_provider.dart';
import 'package:tmdb/shared/domain/media/watch_providers.dart';

WatchProvider buildWatchProvider({
  int providerId = 8,
  String name = 'Netflix',
  String? logoPath = '/netflix.jpg',
  int displayPriority = 0,
}) {
  return WatchProvider(
    providerId: providerId,
    name: name,
    logoPath: logoPath,
    displayPriority: displayPriority,
  );
}

WatchProviders buildWatchProviders({
  String region = 'US',
  String link = 'https://www.themoviedb.org/movie/550/watch?locale=US',
  List<WatchProvider>? stream,
  List<WatchProvider>? rent,
  List<WatchProvider>? buy,
}) {
  return WatchProviders(
    region: region,
    link: link,
    stream: stream ?? [buildWatchProvider()],
    rent: rent ?? const [],
    buy: buy ?? const [],
  );
}
