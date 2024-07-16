import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:itchio/providers/favorite_provider.dart';
import 'package:itchio/providers/jams_provider.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/search_bookmark_provider.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/views/favorite_page.dart';
import 'package:itchio/views/home_page.dart';
import 'package:itchio/views/jams_page.dart';
import 'package:itchio/widgets/carousel_card.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:itchio/widgets/jam_card.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mock_favorite_provider.mocks.dart';
import '../mock_jams_provider.mocks.dart';
import '../mock_saved_searches_provider.mocks.dart';
import '../mock_search_bookmark_provider.mocks.dart';
import '../mock_theme_notifier.mocks.dart';
import 'package:badges/badges.dart' as badges;

void main() {
  group('JamsPage Tests', () {
    late MockJamsProvider mockJamsProvider;
    late MockThemeNotifier mockThemeNotifier;

    setUp(() {
      mockJamsProvider = MockJamsProvider();
      mockThemeNotifier = MockThemeNotifier();

      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
      when(mockThemeNotifier.currentTheme).thenReturn('standard');
    });

    testWidgets('JamsPage test', (WidgetTester tester) async {

      when(mockJamsProvider.fetchJams(false)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [getJam('Jam1'),getJam('Jam2')];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<JamsProvider>(create: (_) => mockJamsProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: JamsPage()),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        for (int i = 0; i < 5; i++) {
          await tester.pump(Duration(seconds: 1));
        }

        expect(find.byType(JamCard), findsNWidgets(2));

      });

    });

    testWidgets('JamsPage filter test', (WidgetTester tester) async {

      when(mockJamsProvider.fetchJams(false)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [getJam('Jam1'),getJam('Jam2')];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<JamsProvider>(create: (_) => mockJamsProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: JamsPage()),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test search');

        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(badges.Badge, "1"), findsOneWidget);

        final clearButtonFinder = find.byIcon(Icons.clear);
        expect(clearButtonFinder, findsOneWidget);
        await tester.tap(clearButtonFinder);
        await tester.pumpAndSettle();

        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work with infinite animations
          await tester.pump(Duration(seconds: 1));
        }

        expect((find.byType(badges.Badge).evaluate().first.widget as badges.Badge).showBadge, false);

        final filterButtonFinder = find.byIcon(Icons.filter_list);
        expect(filterButtonFinder, findsOneWidget);
        await tester.tap(filterButtonFinder);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        final length = find.text("From").evaluate().length;

        for(int i=0; i<length; i++){
          final fromTexts = find.text('From');
          await tester.tap(fromTexts.first);
          await tester.pumpAndSettle();

          final okButtonFinder = find.text('OK');
          await tester.tap(okButtonFinder);
          await tester.pumpAndSettle();

          final toTexts = find.text('To');
          await tester.tap(toTexts.first);
          await tester.pumpAndSettle();

          final okButtonFinder2 = find.text('OK');
          await tester.tap(okButtonFinder2);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.widgetWithText(ElevatedButton, 'Apply Filters'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(badges.Badge, (length * 2).toString()), findsOneWidget);

        await tester.tap(filterButtonFinder);
        await tester.pumpAndSettle();

        final clearChipFinder = find.byKey(const Key('clear_date_chip'));
        for(int i=0; i<length*2; i++){
          await tester.tap(clearChipFinder.first);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(badges.Badge, (length * 2).toString()), findsOneWidget);

        await tester.tap(filterButtonFinder);
        await tester.pumpAndSettle();

        for(int i=0; i<length*2; i++){
          await tester.tap(clearChipFinder.first);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.widgetWithText(ElevatedButton, 'Apply Filters'));
        await tester.pumpAndSettle();

        expect((find.byType(badges.Badge).evaluate().first.widget as badges.Badge).showBadge, false);

      });

    });


    testWidgets('JamsPage refresh test', (WidgetTester tester) async {

      when(mockJamsProvider.fetchJams(false)).thenAnswer((_) async {
        Future.delayed(const Duration(seconds: 1));
        return [getJam('Jam1'),getJam('Jam2')];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<JamsProvider>(create: (_) => mockJamsProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: JamsPage()),
          ),
        );

        final Finder refreshIndicatorFinder = find.byType(RefreshIndicator);

        expect(refreshIndicatorFinder, findsOneWidget);

        await tester.runAsync(() => (refreshIndicatorFinder.evaluate().first.widget as RefreshIndicator).onRefresh());

        for (int i = 0; i < 5; i++) {
          await tester.pump(Duration(seconds: 1));
        }

        await tester.pumpAndSettle();

        verify(mockJamsProvider.reloadJam(false)).called(1);

      });

    });

  });

}

Jam getJam(String title) {

  Map<String, dynamic> gameData = getGame("game").toMap();
  Map<String, dynamic> jamGameData = getJamGame(gameData);

  Map<String, dynamic> jamData = {
    'hue': 120,
    'start_date': '2023-01-01T00:00:00Z',
    'end_date': '2023-01-10T00:00:00Z',
    'voting_end_date': null,
    'featured': 1,
    'id': 1,
    'title': title,
    'highlight': true,
    'joined': 3,
    'url': 'https://sokpop.itch.io/clickyland',
    'detail': {
      'generated_on': 1622548800.0,
      'jam_games': [jamGameData],
    },
  };

  Jam sampleJam = Jam(jamData);

  return sampleJam;
}

Map<String, dynamic> getJamGame(Map<String, dynamic> gameData) {
  Map<String, dynamic> jamGameData = {
    'rating_count': 10,
    'coolness': 5,
    'id': 1,
    'game': gameData,
    'url': 'http://example.com/jam_game/1',
    'created_at': '2023-01-01T00:00:00Z',
    'field_responses': ['Good', 'Fun', 'Challenging'],
  };
  return jamGameData;
}

Game getGame(String title) {
  Map<String, dynamic> gameData = {
    'views_count': 100,
    'url': 'http://example.com/game/1',
    'id': 1,
    'short_text': 'Short description',
    'min_price': 0,
    'price': 0.0,
    'type': 'action',
    'p_windows': false,
    'p_linux': false,
    'p_osx': false,
    'p_android': false,
    'title': title,
    'published_at': '2023-01-01T00:00:00Z',
    'can_be_bought': true,
    'classification': 'indie',
    'created_at': '2023-01-01T00:00:00Z',
    'in_press_system': false,
    'cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'purchases_count': 50,
    'published': true,
    'downloads_count': 200,
    'has_demo': 'No',
    'user': getUser(),
    'still_cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'description': 'Description of the game <img src="http://example.com/image.png">',
    'imageurl': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'author': 'Example Author',
    'currency': 'USD',
  };
  return Game(gameData);
}

Map<String, dynamic> getUser() {
  Map<String, dynamic> userData = {
    'username': 'example_user',
    'url': 'http://example.com/user/1',
    'id': 1,
    'display_name': 'Example User',
    'cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'gamer': true,
    'developer': false,
    'img': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'number_of_projects': '5',
  };
  return userData;
}
