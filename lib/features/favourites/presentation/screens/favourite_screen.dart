import 'package:flutter/material.dart';

import 'package:tmdb/features/favourites/presentation/widgets/favourites_list_view.dart';

/// Standalone favourites screen. The list body lives in [FavouritesListView],
/// which the combined Library tab embeds alongside the watchlist.
class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: const FavouritesListView(),
    );
  }
}
