import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_state.dart';

/// Bookmark icon that toggles whether [item] is saved to the watchlist.
/// Works for both movies and TV shows.
class WatchlistToggleButton extends StatelessWidget {
  const WatchlistToggleButton({super.key, required this.item, this.color});

  final WatchlistItem item;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WatchlistCubit, WatchlistState, bool>(
      selector: (state) => state.contains(item.mediaType, item.id),
      builder: (context, isSaved) {
        final tint = isSaved ? AppColors.cyan : (color ?? Colors.white);
        return IconButton(
          tooltip: isSaved ? 'Remove from watchlist' : 'Add to watchlist',
          icon: Icon(
            isSaved ? IconsaxPlusBold.save_2 : IconsaxPlusLinear.save_2,
            color: tint,
          ),
          onPressed: () => context.read<WatchlistCubit>().toggle(item),
        );
      },
    );
  }
}
