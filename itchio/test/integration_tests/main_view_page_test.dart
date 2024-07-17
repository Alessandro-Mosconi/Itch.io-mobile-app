import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:itchio/providers/favorite_provider.dart';
import 'package:itchio/providers/jams_provider.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/views/favorite_page.dart';
import 'package:itchio/views/home_page.dart';
import 'package:itchio/views/jams_page.dart';
import 'package:itchio/views/main_view.dart';
import 'package:itchio/views/profile_page.dart';
import 'package:itchio/views/search_page.dart';
import 'package:itchio/widgets/bottom_navigation_bar.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:itchio/widgets/jam_card.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_favorite_provider.mocks.dart';
import '../mocks/mock_jams_provider.mocks.dart';
import '../mocks/mock_page_provider.mocks.dart';
import '../mocks/mock_saved_searches_provider.mocks.dart';
import '../mocks/mock_theme_notifier.mocks.dart';

void main() {
  group('MainViewPage Tests', () {
    late MockPageProvider mockPageProvider;
    late MockFavoriteProvider mockFavoriteProvider;
    late MockSavedSearchesProvider mockSavedSearchesProvider;
    late MockThemeNotifier mockThemeNotifier;
    late MockJamsProvider mockJamsProvider;

    setUp(() {
      mockPageProvider = MockPageProvider();
      mockThemeNotifier = MockThemeNotifier();
      mockFavoriteProvider = MockFavoriteProvider();
      mockSavedSearchesProvider = MockSavedSearchesProvider();
      mockJamsProvider = MockJamsProvider();

      when(mockFavoriteProvider.favoriteGames).thenReturn(<Game>[]);
      when(mockFavoriteProvider.favoriteJams).thenReturn(<Jam>[]);

      when(mockFavoriteProvider.fetchFavoriteJams()).thenAnswer((_) async {
        return [];
      });

      when(mockFavoriteProvider.fetchFavoriteGames()).thenAnswer((_) async {
        return [];
      });

      when(mockSavedSearchesProvider.fetchSavedSearch()).thenAnswer((_) async {
        return [];
      });

      when(mockSavedSearchesProvider.savedSearches).thenReturn(<SavedSearch>[]);

      when(mockJamsProvider.fetchJams(any)).thenAnswer((_) async {
        return [];
      });

      when(mockPageProvider.selectedIndex).thenReturn(0);
      when(mockPageProvider.currentExtraPage).thenReturn(HomePage());

      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
      when(mockThemeNotifier.currentTheme).thenReturn('standard');
    });

    testWidgets('MainViewPage tap', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PageProvider>(create: (_) => mockPageProvider),
              ChangeNotifierProvider<FavoriteProvider>(create: (_) => mockFavoriteProvider),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
              ChangeNotifierProvider<JamsProvider>(create: (_) => mockJamsProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: MainView()),
          ),
        );

        expect(find.byType(HomePage), findsOneWidget);

        expect(find.byType(MyBottomNavigationBar), findsOneWidget);

        await tester.tap(find.byIcon(Icons.emoji_events));

        verify(mockPageProvider.setSelectedIndex(any)).called(1);

      });

    });
    testWidgets('MainViewPage go back', (WidgetTester tester) async {

      when(mockPageProvider.selectedIndex).thenReturn(2);
      when(mockPageProvider.currentExtraPage).thenReturn(JamsPage());
      when(mockPageProvider.canGoBack()).thenReturn(true);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PageProvider>(create: (_) => mockPageProvider),
              ChangeNotifierProvider<FavoriteProvider>(create: (_) => mockFavoriteProvider),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
              ChangeNotifierProvider<JamsProvider>(create: (_) => mockJamsProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: MainView()),
          ),
        );

        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pump();

        verify(mockPageProvider.goBack()).called(1);

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
