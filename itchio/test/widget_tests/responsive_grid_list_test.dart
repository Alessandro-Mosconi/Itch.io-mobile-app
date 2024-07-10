import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:itchio/widgets/responsive_grid_list_game.dart';
import 'package:itchio/models/game.dart';

void main() {
  testWidgets('ResponsiveGridList widget test', (WidgetTester tester) async {
    // Create sample games
    final games = [
      getGame('Game 1'),
      getGame('Game 2'),
      getGame('Game 3'),
      getGame('Game 4'),
      getGame('Game 5'),
      getGame('Game 6'),
      getGame('Game 7'),
      getGame('Game 8'),
      getGame('Game 9'),
      getGame('Game 10'),
    ];

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveGridListGame(games: games),
        ),
      ),
    );

    // Verify the widget builds the correct layout for mobile (list)
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GameCard), findsNWidgets(10));

    tester.view.physicalSize = Size(800, 600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveGridListGame(games: games),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(GameCard), findsNWidgets(10));

    // Change orientation to landscape and verify the grid layout
    tester.view.physicalSize = Size(1200, 600);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveGridListGame(games: games),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(GameCard), findsNWidgets(10));

    // Verify the crossAxisCount for landscape
    final gridView = tester.widget<GridView>(find.byType(GridView));
    final gridDelegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(gridDelegate.crossAxisCount, 4);
  });
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
    'number_of_projects': "5",
  };
  return userData;
}
