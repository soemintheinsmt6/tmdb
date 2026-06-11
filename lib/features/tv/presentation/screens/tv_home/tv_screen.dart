import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/responsive_builder.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_bloc.dart';
import 'package:tmdb/injection_container.dart';

import 'layouts/tv_mobile_layout.dart';
import 'layouts/tv_tablet_layout.dart';

/// Routes between mobile and tablet TV layouts.
class TvScreen extends StatelessWidget {
  const TvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TvListBloc>()),
        BlocProvider(create: (_) => sl<TvSearchBloc>()),
      ],
      child: ResponsiveBuilder(
        mobile: (_, __) => const TvMobileLayout(),
        tablet: (_, __) => const TvTabletLayout(),
      ),
    );
  }
}
