import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_bloc.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_event.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_state.dart';
import 'package:tmdb/features/people/presentation/widgets/person_detail_cards.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';

/// Single layout for the person detail screen — unlike the movie/TV screens it
/// has no backdrop hero, so one width-adaptive layout (via [horizontalPadding])
/// covers both mobile and tablet.
class PersonDetailLayout extends StatelessWidget {
  const PersonDetailLayout({
    super.key,
    required this.personId,
    this.fallbackName,
    this.horizontalPadding = 16,
  });

  final int personId;
  final String? fallbackName;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: BlocBuilder<PersonDetailBloc, PersonDetailState>(
          builder: (context, state) {
            final name = state is PersonDetailLoaded
                ? state.person.name
                : (fallbackName ?? '');
            return Text(name);
          },
        ),
      ),
      body: BlocBuilder<PersonDetailBloc, PersonDetailState>(
        builder: (context, state) {
          if (state is PersonDetailLoaded) {
            final person = state.person;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonHeader(person: person),
                      const SizedBox(height: 24),
                      PersonBiography(biography: person.biography),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PersonFilmography(
                  credits: person.filmography,
                  horizontalPadding: horizontalPadding,
                ),
                const SizedBox(height: 24),
              ],
            );
          }
          if (state is PersonDetailError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<PersonDetailBloc>().add(
                PersonDetailFetched(personId),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
