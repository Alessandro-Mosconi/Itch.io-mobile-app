import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:itchio/providers/favorite_provider.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/views/favorite_page.dart';
import 'package:itchio/widgets/carousel_card.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:itchio/widgets/jam_card.dart';
import 'package:itchio/widgets/saved_search_list.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mock_favorite_provider.mocks.dart';
import '../mock_saved_searches_provider.mocks.dart';
import '../mock_theme_notifier.mocks.dart';

void main() {
  group('SavedSearchList Tests', () {
    late MockSavedSearchesProvider mockSavedSearchesProvider;
    final Logger logger = Logger(printer: PrettyPrinter());

    setUp(() {
      mockSavedSearchesProvider = MockSavedSearchesProvider();

      when(mockSavedSearchesProvider.savedSearches).thenReturn(<SavedSearch>[]);
    });

    testWidgets('SavedSearchList Empty messages', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
            ],
            child: const MaterialApp(home: SavedSearchList(savedSearches: [])),
          ),
        );

        expect(find.text('No saved searches yet'), findsOne);

      });

    });
    testWidgets('SavedSearchList essential', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
            ],
            child: MaterialApp(home: SavedSearchList(savedSearches: [
              SavedSearch(type: 'type', filters: 'filters', notify: false, items: [getGame('Game 1'), getGame('Game 2')]),
              SavedSearch(type: 'type2', filters: 'filters2', notify: false, items: [getGame('Game 4'), getGame('Game 3')])
            ])),
          ),
        );

        expect(find.byType(CarouselCard), findsNWidgets(2));

      });

    });

  });

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
