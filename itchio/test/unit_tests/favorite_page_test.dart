import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/providers/favorite_provider.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/views/favorite_page.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:itchio/widgets/jam_card.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mock_favorite_provider.mocks.dart';
import '../mock_theme_notifier.mocks.dart';

void main() {
  group('FavoritePage Tests', () {
    late MockFavoriteProvider mockFavoriteProvider;
    late MockThemeNotifier mockThemeNotifier;

    setUp(() {
      mockFavoriteProvider = MockFavoriteProvider();
      mockThemeNotifier = MockThemeNotifier();

      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
      when(mockThemeNotifier.currentTheme).thenReturn('standard');
    });

    testWidgets('HomePage Empty messages', (WidgetTester tester) async {
      when(mockFavoriteProvider.favoriteGames).thenReturn([]);
      when(mockFavoriteProvider.favoriteJams).thenReturn([]);

      when(mockFavoriteProvider.fetchFavoriteGames()).thenAnswer((_) async {
        return [];
      });
      when(mockFavoriteProvider.fetchFavoriteJams()).thenAnswer((_) async {
        return [];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FavoriteProvider>(create: (_) => mockFavoriteProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: FavoritePage()),
          ),
        );

        expect(find.text('Games'), findsOne);
        expect(find.text('Jams'), findsOne);

        expect(find.text('No favorite games yet'), findsOne);

        final Finder tabBar = find.byType(TabBar);
        final Finder jamsTab = find.descendant(of: tabBar, matching: find.text('Jams'));

        await tester.tap(jamsTab);

        for (int i = 0; i < 5; i++) {
          await tester.pump(Duration(seconds: 1));
        }

        expect(find.text('No favorite jams yet'), findsOne);

      });

    });


    testWidgets('HomePage with cards messages', (WidgetTester tester) async {
      when(mockFavoriteProvider.favoriteGames).thenReturn([getGame("Title1"),getGame("Title2")]);
      when(mockFavoriteProvider.favoriteJams).thenReturn([getJam("Jam1"),getJam("Jam2")]);

      when(mockFavoriteProvider.fetchFavoriteGames()).thenAnswer((_) async {
        return [];
      });
      when(mockFavoriteProvider.fetchFavoriteJams()).thenAnswer((_) async {
        return [];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FavoriteProvider>(create: (_) => mockFavoriteProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: FavoritePage()),
          ),
        );

        expect(find.text('Games'), findsOne);
        expect(find.text('Jams'), findsOne);

        expect(find.byType(GameCard), findsNWidgets(2));

        final Finder tabBar = find.byType(TabBar);
        final Finder jamsTab = find.descendant(of: tabBar, matching: find.text('Jams'));

        await tester.tap(jamsTab);

        for (int i = 0; i < 5; i++) {
          await tester.pump(Duration(seconds: 1));
        }

        expect(find.byType(JamCard), findsNWidgets(2));

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
