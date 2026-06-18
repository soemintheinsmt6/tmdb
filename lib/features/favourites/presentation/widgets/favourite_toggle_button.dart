import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';

/// Heart icon that toggles whether [item] is stored as a favourite.
/// Works for both movies and TV shows.
class FavouriteToggleButton extends StatelessWidget {
  const FavouriteToggleButton({super.key, required this.item, this.color});

  final FavouriteItem item;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavouritesCubit, FavouritesState, bool>(
      selector: (state) => state.contains(item.mediaType, item.id),
      builder: (context, isFav) {
        final tint = isFav ? AppColors.cyan : (color ?? Colors.white);
        return IconButton(
          tooltip: isFav ? 'Remove from favourites' : 'Add to favourites',
          icon: Icon(
            isFav ? IconsaxPlusBold.heart : IconsaxPlusLinear.heart,
            color: tint,
          ),
          onPressed: () => context.read<FavouritesCubit>().toggle(item),
        );
      },
    );
  }
}
