import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/shared/domain/watch_providers.dart';
import 'package:tmdb/shared/widgets/watch_providers_section.dart';

import '../../helpers/watch_provider_fixtures.dart';

void main() {
  // `logoPath: null` keeps the section off the network so the test is hermetic.
  Future<void> pump(WidgetTester tester, WatchProviders? providers) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: WatchProvidersSection(providers: providers)),
      ),
    );
  }

  testWidgets('shows only the categories that have providers', (tester) async {
    await pump(
      tester,
      buildWatchProviders(
        region: 'GB',
        stream: [buildWatchProvider(name: 'Netflix', logoPath: null)],
        rent: [
          buildWatchProvider(providerId: 2, name: 'Apple TV', logoPath: null),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('Where to Watch'), findsOneWidget);
    expect(find.text('GB'), findsOneWidget); // region badge
    expect(find.text('Stream'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Buy'), findsNothing);
    expect(find.text('JustWatch'), findsOneWidget);
  });

  testWidgets('renders nothing when providers is null', (tester) async {
    await pump(tester, null);
    await tester.pump();

    expect(find.text('Where to Watch'), findsNothing);
  });

  testWidgets('renders nothing when the region has no offerings', (
    tester,
  ) async {
    await pump(
      tester,
      buildWatchProviders(stream: const [], rent: const [], buy: const []),
    );
    await tester.pump();

    expect(find.text('Where to Watch'), findsNothing);
  });
}
