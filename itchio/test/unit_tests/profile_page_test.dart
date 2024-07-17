import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/User.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/models/purchased_game.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/providers/user_provider.dart';
import 'package:itchio/services/oauth_service.dart';
import 'package:itchio/views/profile_page.dart';
import 'package:itchio/views/settings_page.dart';
import 'package:itchio/widgets/developed_game_card.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mock_oauth_service.mocks.dart';
import '../mock_page_provider.mocks.dart';
import '../mock_theme_notifier.mocks.dart';
import '../mock_user_provider.mocks.dart';

void main() {
  group('ProfilePage Tests', () {
    late MockUserProvider mockUserProvider;
    late MockThemeNotifier mockThemeNotifier;
    late MockOAuthService mockOAuthService;
    late MockPageProvider mockPageProvider;

    setUp(() {
      mockUserProvider = MockUserProvider();
      mockThemeNotifier = MockThemeNotifier();
      mockOAuthService = MockOAuthService();
      mockPageProvider = MockPageProvider();

      when(mockOAuthService.accessToken).thenReturn('token');

      when(mockUserProvider.fetchUser(any)).thenAnswer((_) async {
        return User(getUser());
      });

      when(mockUserProvider.fetchDevelopedGames(any)).thenAnswer((_) async {
        return [];
      });

      when(mockUserProvider.fetchPurchasedGames(any)).thenAnswer((_) async {
        return [];
      });

      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
      when(mockThemeNotifier.currentTheme).thenReturn('standard');
    });

    testWidgets('ProfilePage Empty messages', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>(create: (_) => mockUserProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
              ,              ChangeNotifierProvider<OAuthService>(create: (_) => mockOAuthService)
            ],
            child: const MaterialApp(home: ProfilePage()),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.pumpAndSettle();

        expect(find.byType(TabBar), findsOne);
        expect(find.text('Developed Games'), findsOne);

        expect(find.text('@example_user'), findsOne);
        expect(find.text('Developer'), findsOne);
        expect(find.text('Gamer'), findsOne);

        expect(find.text('No developed games found'), findsOne);

        expect(find.text('Purchased Games'), findsOne);
        await tester.tap(find.text('Purchased Games'));
        await tester.pumpAndSettle();

        expect(find.text("No purchased games found"), findsOne);


      });

    });

    testWidgets('ProfilePage Developed and Purchased games', (WidgetTester tester) async {

      when(mockUserProvider.fetchDevelopedGames(any)).thenAnswer((_) async {
        return [getGame("Game 1")];
      });

      when(mockUserProvider.fetchPurchasedGames(any)).thenAnswer((_) async {
        return [getPurchasedGame('Purchased Game 1')];
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>(create: (_) => mockUserProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
              ,              ChangeNotifierProvider<OAuthService>(create: (_) => mockOAuthService)
            ],
            child: const MaterialApp(home: ProfilePage()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Game 1'), findsOne);
        expect(find.byType(DevelopedGameCard), findsOne);

        await tester.tap(find.text('Purchased Games'));
        await tester.pumpAndSettle();

        expect(find.text('Purchased Game 1'), findsOne);
        expect(find.byType(GameCard), findsOne);


      });

    });

    testWidgets('ProfilePage Open settings', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>(create: (_) => mockUserProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
              ChangeNotifierProvider<PageProvider>(create: (_) => mockPageProvider),
              ChangeNotifierProvider<OAuthService>(create: (_) => mockOAuthService)
            ],
            child: const MaterialApp(home: ProfilePage()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        expect(find.byType(SettingsPage), findsOneWidget);


      });

    });

    testWidgets('ProfilePage No ticket', (WidgetTester tester) async {

      when(mockOAuthService.accessToken).thenReturn(null);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>(create: (_) => mockUserProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
              ChangeNotifierProvider<PageProvider>(create: (_) => mockPageProvider),
              ChangeNotifierProvider<OAuthService>(create: (_) => mockOAuthService)
            ],
            child: const MaterialApp(home: ProfilePage()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Authenticate'), findsOneWidget);

      });

    });

    testWidgets('ProfilePage Tablet layout', (WidgetTester tester) async {

      tester.binding.window.physicalSizeTestValue = Size(1600, 1200); // Tablet screen size
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>(create: (_) => mockUserProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
              ChangeNotifierProvider<PageProvider>(create: (_) => mockPageProvider),
              ChangeNotifierProvider<OAuthService>(create: (_) => mockOAuthService)
            ],
            child: const MaterialApp(home: ProfilePage()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TabBar), findsNothing);
        expect(find.text('Developed Games'), findsOne);
        expect(find.text('Purchased Games'), findsOne);

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
    'developer': true,
    'img': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'number_of_projects': '5',
  };
  return userData;
}

PurchaseGame getPurchasedGame(String title) {

  return PurchaseGame(
    {
      'game_id' : 11,
      'purchase_id' : 32,
      'created_at' : '',
      'updated_at' : '',
      'id' : 1,
      'download' : 23,
      'game' : getGame(title).toMap(),
    }
  );
}
