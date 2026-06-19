import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/tv/presentation/widgets/episode_tile.dart';
import 'package:tmdb/shared/widgets/common/rating_badge.dart';

import '../../../../helpers/tv_fixtures.dart';

void main() {
  // `stillPath: null` keeps the tile off the network so the test stays hermetic.
  Future<void> pump(WidgetTester tester, {String airDate = '2011-04-17'}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 380,
            child: EpisodeTile(
              episode: buildEpisode(stillPath: null, airDate: airDate),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders the prettified air date, runtime and rating', (
    tester,
  ) async {
    await pump(tester);
    await tester.pump();

    expect(find.text('Apr 17, 2011  ·  62 min'), findsOneWidget);
    expect(find.byType(RatingBadge), findsOneWidget);
    // A clean layout — no RenderFlex overflow during pump.
    expect(tester.takeException(), isNull);
  });

  testWidgets('omits the date when it is unparseable, keeping runtime', (
    tester,
  ) async {
    await pump(tester, airDate: '');
    await tester.pump();

    expect(find.text('62 min'), findsOneWidget);
  });
}
