import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/shared/widgets/imdb_chip.dart';

void main() {
  testWidgets('renders the IMDb label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: ImdbChip(imdbId: 'tt0137523')),
        ),
      ),
    );

    expect(find.text('IMDb'), findsOneWidget);
    expect(find.byType(ImdbChip), findsOneWidget);
  });
}
