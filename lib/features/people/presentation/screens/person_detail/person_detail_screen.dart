import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/responsive/responsive_builder.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_bloc.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_event.dart';
import 'package:tmdb/injection_container.dart';

import 'layouts/person_detail_layout.dart';

class PersonDetailScreen extends StatelessWidget {
  const PersonDetailScreen({super.key, required this.personId, this.name});

  final int personId;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PersonDetailBloc>()..add(PersonDetailFetched(personId)),
      child: ResponsiveBuilder(
        builder: (ctx, _, __) => PersonDetailLayout(
          personId: personId,
          fallbackName: name,
          horizontalPadding: ctx.horizontalPadding,
        ),
      ),
    );
  }
}
