import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/widgets/responsive_grid_list_game.dart';
import 'package:itchio/widgets/responsive_grid_list_jams.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('ResponsiveGridList game widget test', (WidgetTester tester) async {
    final games = [getGame('Game 1'), getGame('Game 2')];

    // Mock network images for the entire test
    await mockNetworkImagesFor(() async {
      // Initial pump with a small screen size to expect a ListView
      await tester.pumpWidget(MaterialApp(home: ResponsiveGridListGame(games: games)));
      tester.view.physicalSize = const Size(500, 800);
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);

      // Change the physical size to simulate a larger screen
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      // Rebuild the widget tree with the new screen size
      await tester.pumpWidget(MaterialApp(home: ResponsiveGridListGame(games: games)));
      await tester.pumpAndSettle();

      // Now we expect a GridView because of the larger screen
      expect(find.byType(GridView), findsOneWidget);
    });

    // Reset the physical size after the test
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('ResponsiveGridList jam widget test', (WidgetTester tester) async {
    final jams = [getJam('Jam 1'), getJam('Jam 2')];

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(home: ResponsiveGridListJam(jams: jams)));
      tester.view.physicalSize = const Size(500, 800);
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);

      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(home: ResponsiveGridListJam(jams: jams)));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    // Reset the physical size after the test
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
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
    'number_of_projects': "5",
  };
  return userData;
}
