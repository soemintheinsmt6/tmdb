import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/features/movies/presentation/widgets/collection_skeleton.dart';

void main() {
  testWidgets('renders a shimmering placeholder grid without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: CollectionSkeleton(itemCount: 4)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Shimmer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
