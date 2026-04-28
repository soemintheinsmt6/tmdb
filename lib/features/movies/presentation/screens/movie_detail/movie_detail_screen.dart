import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/responsive_builder.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_event.dart';
import 'package:tmdb/injection_container.dart';

import 'layouts/movie_detail_mobile_layout.dart';
import 'layouts/movie_detail_tablet_layout.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.title});

  final int movieId;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<MovieDetailBloc>()..add(MovieDetailFetched(movieId)),
      child: ResponsiveBuilder(
        mobile: (_, __) => MovieDetailMobileLayout(fallbackTitle: title),
        tablet: (_, __) => MovieDetailTabletLayout(fallbackTitle: title),
      ),
    );
  }
}
