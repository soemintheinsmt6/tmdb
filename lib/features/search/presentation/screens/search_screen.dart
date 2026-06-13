import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:tmdb/features/search/presentation/widgets/search_content.dart';
import 'package:tmdb/injection_container.dart';

/// Global multi-search tab. One query box searches movies, TV shows and people
/// via `/search/multi`; each result routes to its own detail screen.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: Scaffold(
        appBar: AppBar(titleSpacing: 0, title: const Text('Browse')),
        body: const SafeArea(child: SearchContent()),
      ),
    );
  }
}
