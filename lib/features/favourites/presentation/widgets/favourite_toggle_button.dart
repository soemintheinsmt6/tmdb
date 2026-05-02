import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

/// Heart icon that toggles whether [movie] is stored as a favourite.
class FavouriteToggleButton extends StatelessWidget {
  const FavouriteToggleButton({
    super.key,
    required this.movie,
    this.color,
  });

  final Movie movie;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavouritesCubit, List<FavouriteMovie>>(
      builder: (context, favourites) {
        final isFav = favourites.any((f) => f.movieId == movie.id);
        final tint = isFav ? AppColors.cyan : (color ?? Colors.white);
        return IconButton(
          tooltip: isFav ? 'Remove from favourites' : 'Add to favourites',
          icon: Icon(
            isFav ? IconsaxPlusBold.heart : IconsaxPlusLinear.heart,
            color: tint,
          ),
          onPressed: () => context.read<FavouritesCubit>().toggle(movie),
        );
      },
    );
  }
}
