import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/presentation/bloc/collection_bloc/collection_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/collection_bloc/collection_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/collection_bloc/collection_state.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/movies/presentation/widgets/collection_skeleton.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';
import 'package:tmdb/shared/widgets/poster_card.dart';

/// All films in a movie franchise, from `/collection/{id}`. Reached by tapping
/// the "Part of …" banner on a movie detail screen; each film routes back into
/// movie detail. The backdrop flies in from the banner via a shared-element
/// [Hero] (seeded so the target exists while the parts load).
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.collectionId,
    required this.title,
    this.seedBackdropPath,
    this.heroTag,
  });

  final int collectionId;
  final String title;
  final String? seedBackdropPath;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CollectionBloc>()..add(CollectionFetched(collectionId)),
      child: Scaffold(
        appBar: AppBar(titleSpacing: 0, title: Text(title)),
        body: BlocBuilder<CollectionBloc, CollectionState>(
          builder: (context, state) {
            final loaded = state is CollectionLoaded ? state.collection : null;
            // Prefer the loaded backdrop, fall back to the seed so the hero
            // target is on-screen immediately while the parts load.
            final backdrop = loaded?.backdropPath ?? seedBackdropPath;
            final hasHeader =
                (backdrop != null && backdrop.isNotEmpty) || heroTag != null;
            final columns = context.posterGridColumns;
            final aspectRatio = context.posterCardAspectRatio;

            return CustomScrollView(
              slivers: [
                if (hasHeader)
                  SliverToBoxAdapter(
                    child: DetailHeader(
                      backdropPath: backdrop,
                      heroTag: heroTag,
                    ),
                  ),
                if (loaded != null) ...[
                  if (loaded.overview.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        child: DetailOverview(overview: loaded.overview),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: loaded.parts.length,
                      itemBuilder: (_, index) {
                        final movie = loaded.parts[index];
                        return PosterCard(
                          item: movie,
                          onTap: () => pushView(
                            context,
                            MovieDetailScreen(
                              movieId: movie.id,
                              title: movie.title,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (state is CollectionError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: AppErrorView(
                        message: state.message,
                        onRetry: () => context.read<CollectionBloc>().add(
                          CollectionFetched(collectionId),
                        ),
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: CollectionSkeleton()),
              ],
            );
          },
        ),
      ),
    );
  }
}
