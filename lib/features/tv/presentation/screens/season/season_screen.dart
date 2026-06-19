import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/features/tv/domain/entities/season_detail.dart';
import 'package:tmdb/features/tv/presentation/bloc/season_detail_bloc/season_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/season_detail_bloc/season_detail_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/season_detail_bloc/season_detail_state.dart';
import 'package:tmdb/features/tv/presentation/widgets/episode_tile.dart';
import 'package:tmdb/features/tv/presentation/widgets/season_detail_skeleton.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';

/// Episode list for a single season of a TV show. Loads `/tv/{id}/season/{n}`
/// via its own [SeasonDetailBloc]; reached by tapping a season on TV detail.
class SeasonScreen extends StatelessWidget {
  const SeasonScreen({
    super.key,
    required this.tvShowId,
    required this.seasonNumber,
    required this.title,
  });

  final int tvShowId;
  final int seasonNumber;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SeasonDetailBloc>()
        ..add(
          SeasonDetailFetched(tvShowId: tvShowId, seasonNumber: seasonNumber),
        ),
      child: Scaffold(
        appBar: AppBar(titleSpacing: 0, title: Text(title)),
        body: BlocBuilder<SeasonDetailBloc, SeasonDetailState>(
          builder: (context, state) {
            if (state is SeasonDetailLoaded) {
              return _SeasonBody(detail: state.detail);
            }
            if (state is SeasonDetailError) {
              return AppErrorView(
                message: state.message,
                onRetry: () => context.read<SeasonDetailBloc>().add(
                  SeasonDetailFetched(
                    tvShowId: tvShowId,
                    seasonNumber: seasonNumber,
                  ),
                ),
              );
            }
            return const SeasonDetailSkeleton();
          },
        ),
      ),
    );
  }
}

class _SeasonBody extends StatelessWidget {
  const _SeasonBody({required this.detail});

  final SeasonDetail detail;

  @override
  Widget build(BuildContext context) {
    final episodes = detail.episodes;
    if (episodes.isEmpty) {
      return const AppEmptyView(
        message: 'No episodes for this season yet',
        icon: IconsaxPlusLinear.video_slash,
      );
    }

    final hasHeader = detail.overview.isNotEmpty;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: episodes.length + (hasHeader ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (hasHeader && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              detail.overview,
              style: AppTypography.bodyText.copyWith(
                color: context.colors.textSecondary,
                height: 1.6,
              ),
            ),
          );
        }
        final episode = episodes[index - (hasHeader ? 1 : 0)];
        return EpisodeTile(episode: episode);
      },
    );
  }
}
