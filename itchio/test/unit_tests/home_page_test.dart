import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:itchio/providers/favorite_provider.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/search_bookmark_provider.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/views/home_page.dart';
import 'package:itchio/widgets/carousel_card.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mock_favorite_provider.mocks.dart';
import '../mock_saved_searches_provider.mocks.dart';
import '../mock_search_bookmark_provider.mocks.dart';
import '../mock_theme_notifier.mocks.dart';

void main() {
  group('HomePage Tests', () {
    late MockFavoriteProvider mockFavoriteProvider;
    late MockSearchBookmarkProvider mockSearchBookmarkProvider;
    late MockSavedSearchesProvider mockSavedSearchesProvider;
    late MockThemeNotifier mockThemeNotifier;

    setUp(() {
      mockFavoriteProvider = MockFavoriteProvider();
      mockSearchBookmarkProvider = MockSearchBookmarkProvider();
      mockSavedSearchesProvider = MockSavedSearchesProvider();
      mockThemeNotifier = MockThemeNotifier();

      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
      when(mockThemeNotifier.currentTheme).thenReturn('standard');
    });

    testWidgets('HomePage shows CircularProgressIndicator then carouse card', (WidgetTester tester) async {
      when(mockSavedSearchesProvider.fetchSavedSearch()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [getSavedSearch('filter1'),getSavedSearch('filter2')];
      });
      when(mockFavoriteProvider.fetchFavoriteGames()).thenAnswer((_) async {
        return [];
      });
      when(mockFavoriteProvider.fetchFavoriteJams()).thenAnswer((_) async {
        return [];
      });
      when(mockSearchBookmarkProvider.fetchBookmarks()).thenAnswer((_) async {
        return [];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FavoriteProvider>(create: (_) => mockFavoriteProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
            ],
            child: const MaterialApp(home: HomePage()),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work with infinite animations
          await tester.pump(Duration(seconds: 1));
        }

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(CarouselCard), findsNWidgets(2));
      });

    });
    testWidgets('HomePage shows CircularProgressIndicator then nothing', (WidgetTester tester) async {
      when(mockSavedSearchesProvider.fetchSavedSearch()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [];
      });
      when(mockFavoriteProvider.fetchFavoriteGames()).thenAnswer((_) async {
        return [];
      });
      when(mockFavoriteProvider.fetchFavoriteJams()).thenAnswer((_) async {
        return [];
      });
      when(mockSearchBookmarkProvider.fetchBookmarks()).thenAnswer((_) async {
        return [];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FavoriteProvider>(create: (_) => mockFavoriteProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
            ],
            child: const MaterialApp(home: HomePage()),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work with infinite animations
          await tester.pump(Duration(seconds: 1));
        }

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('No saved searches yet'), findsOneWidget);
      });

    });
    testWidgets('HomePage refresh test', (WidgetTester tester) async {
      when(mockSavedSearchesProvider.fetchSavedSearch()).thenAnswer((_) async {
        return [];
      });
      when(mockFavoriteProvider.fetchFavoriteGames()).thenAnswer((_) async {
        return [];
      });
      when(mockFavoriteProvider.fetchFavoriteJams()).thenAnswer((_) async {
        return [];
      });
      when(mockSearchBookmarkProvider.fetchBookmarks()).thenAnswer((_) async {
        return [];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FavoriteProvider>(create: (_) => mockFavoriteProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
            ],
            child: const MaterialApp(home: HomePage()),
          ),
        );

        await tester.fling(find.byType(RefreshIndicator), const Offset(0, 500), 2000);
        await tester.pump();

        verify(mockSavedSearchesProvider.fetchSavedSearch()).called(2);
      });

    });

  });

}

SavedSearch getSavedSearch(String filters) {
  Map<String, dynamic> savedSearchData = {
    'type': 'games',
    'filters': filters,
    'notify': true,
    'items': [getGame('Game 1').toMap(), getGame('Game 2').toMap()]
  };
  return SavedSearch(savedSearchData);
}

Game getGame(String title) {
  Map<String, dynamic> gameData = {
    'views_count': 100,
    'url': 'http://example.com/game/1',
    'id': 1,
    'short_text': 'Short description of the game',
    'min_price': 0,
    'price': 0.0,
    'type': 'action',
    'p_windows': true,
    'p_linux': true,
    'p_osx': true,
    'p_android': true,
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
