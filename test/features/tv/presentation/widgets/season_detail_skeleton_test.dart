import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/features/tv/presentation/widgets/season_detail_skeleton.dart';

void main() {
  testWidgets('renders shimmering placeholder rows without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SeasonDetailSkeleton(itemCount: 3)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Shimmer), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
