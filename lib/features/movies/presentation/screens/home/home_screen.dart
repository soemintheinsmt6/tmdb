import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/responsive_builder.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:tmdb/injection_container.dart';

import 'layouts/home_mobile_layout.dart';
import 'layouts/home_tablet_layout.dart';

/// Routes between mobile and tablet home layouts.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MovieListBloc>()),
        BlocProvider(create: (_) => sl<MovieSearchBloc>()),
      ],
      child: ResponsiveBuilder(
        mobile: (_, __) => const HomeMobileLayout(),
        tablet: (_, __) => const HomeTabletLayout(),
      ),
    );
  }
}
