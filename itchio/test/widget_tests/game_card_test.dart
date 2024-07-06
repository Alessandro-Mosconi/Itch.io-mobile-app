import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/customIcons/custom_icon_icons.dart';

import 'package:itchio/models/game.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:logger/logger.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {

  final bool isUrlInvalid;

  const MyApp(this.isUrlInvalid, {super.key});

  @override
  Widget build(BuildContext context) {
    Game game = getGame(isUrlInvalid);
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: ChangeNotifierProvider<PageProvider>(
          create: (_) => PageProvider(),
          child: GameCard(game: game,),
        ),
      ),
    );
  }
}

void main() {
  final Logger logger = Logger(printer: PrettyPrinter());

  testWidgets('Game card test', (WidgetTester tester) async {

    Game game = getGame(false);

    await mockNetworkImagesFor(() => tester.pumpWidget(const MyApp(false)));

    expect(find.text(game.title!), findsOneWidget);
    expect(find.text(game.getCleanDescription()!), findsOneWidget);
    expect(find.text(game.getFormatPriceWithCurrency()), findsOneWidget);

    final iconWindowsFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == CustomIcon.windows);
    final iconLinuxFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == CustomIcon.linux);
    final iconMacFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == Icons.apple);
    final iconAndroidFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == Icons.android);

    expect(iconWindowsFinder, findsOneWidget);
    expect(iconLinuxFinder, findsOneWidget);
    expect(iconMacFinder, findsOneWidget);
    expect(iconAndroidFinder, findsOneWidget);


    //TEST TAP ON JAM

    await tester.tap(find.byKey(const Key('game_card_gesture_detector')));

    await tester.pumpAndSettle();
    //TODO da verificare davvero
    //expect(find.byType(GameWebViewPage), findsOneWidget);

  });

  testWidgets('Game card url non valido test', (WidgetTester tester) async {

    Game game = getGame(true);

    await mockNetworkImagesFor(() => tester.pumpWidget(const MyApp(true)));

    expect(find.text(game.title!), findsOneWidget);
    expect(find.text(game.getCleanDescription()!), findsOneWidget);
    expect(find.text(game.getFormatPriceWithCurrency()), findsOneWidget);

    final iconWindowsFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == CustomIcon.windows);
    final iconLinuxFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == CustomIcon.linux);
    final iconMacFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == Icons.apple);
    final iconAndroidFinder = find.byWidgetPredicate((Widget widget) => widget is Icon && widget.icon == Icons.android);

    expect(iconWindowsFinder, findsOneWidget);
    expect(iconLinuxFinder, findsOneWidget);
    expect(iconMacFinder, findsOneWidget);
    expect(iconAndroidFinder, findsOneWidget);


    //TEST TAP ON JAM
    await tester.tap(find.byKey(const Key('game_card_gesture_detector')));
    await tester.pumpAndSettle();


    expect(find.text(game.title!), findsOneWidget);
    expect(find.text(game.getCleanDescription()!), findsOneWidget);
    expect(find.text(game.getFormatPriceWithCurrency()), findsOneWidget);

    expect(iconWindowsFinder, findsOneWidget);
    expect(iconLinuxFinder, findsOneWidget);
    expect(iconMacFinder, findsOneWidget);
    expect(iconAndroidFinder, findsOneWidget);


  });
}


Game getGame(bool isUrlInvalid) {
  Map<String, dynamic> gameData = {
    'views_count': 100,
    'url': isUrlInvalid ? null : 'http://example.com/game/1',
    'id': 1,
    'short_text': 'Short description of the game',
    'min_price': 0,
    'price': 0.0,
    'type': 'action',
    'p_windows': true,
    'p_linux': true,
    'p_osx': true,
    'p_android': true,
    'title': 'Sample Game',
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
