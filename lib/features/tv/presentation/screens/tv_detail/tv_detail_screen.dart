import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/responsive_builder.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_event.dart';
import 'package:tmdb/injection_container.dart';

import 'layouts/tv_detail_mobile_layout.dart';
import 'layouts/tv_detail_tablet_layout.dart';

class TvDetailScreen extends StatelessWidget {
  const TvDetailScreen({
    super.key,
    required this.tvShowId,
    this.title,
    this.backdropPath,
    this.heroTag,
  });

  final int tvShowId;
  final String? title;
  final String? backdropPath;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TvDetailBloc>()..add(TvDetailFetched(tvShowId)),
      child: ResponsiveBuilder(
        mobile: (_, __) => TvDetailMobileLayout(
          tvShowId: tvShowId,
          fallbackTitle: title,
          seedBackdropPath: backdropPath,
          heroTag: heroTag,
        ),
        tablet: (_, __) => TvDetailTabletLayout(
          tvShowId: tvShowId,
          fallbackTitle: title,
          seedBackdropPath: backdropPath,
          heroTag: heroTag,
        ),
      ),
    );
  }
}
