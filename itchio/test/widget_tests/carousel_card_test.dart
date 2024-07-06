import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:itchio/widgets/carousel_card.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';



void main() {
  group('CarouselCard Tests', () {
    testWidgets('Widget Initialization Test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: ChangeNotifierProvider<PageProvider>(
              create: (_) => PageProvider(),
              child: CarouselCard(
                title: 'Featured Games',
                subtitle: 'Subtitle',
                items: [
                  getGame("Game 1"),
                  getGame("Game 2"),
                ],
                notify: true,
                onUpdateSavedSearches: (bool value) {},
              ),
            ),
          ),
        ));

        expect(find.byType(CarouselCard), findsOneWidget);
        expect(find.text('Featured games'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
      });
    });
    testWidgets('Dismiss delete test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: ChangeNotifierProvider<PageProvider>(
              create: (_) => PageProvider(),
              child: CarouselCard(
                title: 'Featured Games',
                subtitle: 'Subtitle',
                items: [
                  getGame("Game 1"),
                  getGame("Game 2"),
                ],
                notify: true,
                onUpdateSavedSearches: (bool value) {},
              ),
            ),
          ),
        ));

        final dismissibleFinder = find.byType(Dismissible);

        // Check if the Dismissible widget is present
        expect(dismissibleFinder, findsOneWidget);

        // Trigger dismiss in one direction (e.g., right)
        await tester.drag(dismissibleFinder, const Offset(-1000, 0));
        await tester.pumpAndSettle();

        var cancelButtonFinder = find.widgetWithText(TextButton, 'Cancel');
        expect(cancelButtonFinder, findsOneWidget);
        await tester.tap(cancelButtonFinder);
        await tester.pumpAndSettle();

        expect(find.byType(CarouselCard), findsOneWidget);
        expect(find.text('Featured games'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);
        expect(find.text('Confirm'), findsNothing);

        await tester.drag(dismissibleFinder, const Offset(-1000, 0));
        await tester.pumpAndSettle();

        var confirmButtonFinder = find.widgetWithText(ElevatedButton, 'Confirm');
        expect(confirmButtonFinder, findsOneWidget);
        await tester.tap(confirmButtonFinder);
        await tester.pumpAndSettle();

        //TODO CAPIRE COME TESTARE DELTE

      });
    });
    testWidgets('Dismiss search test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: ChangeNotifierProvider<PageProvider>(
              create: (_) => PageProvider(),
              child: CarouselCard(
                title: 'Featured Games',
                subtitle: 'Subtitle',
                items: [
                  getGame("Game 1"),
                  getGame("Game 2"),
                ],
                notify: true,
                onUpdateSavedSearches: (bool value) {},
              ),
            ),
          ),
        ));

        final dismissibleFinder = find.byType(Dismissible);

        // Check if the Dismissible widget is present
        expect(dismissibleFinder, findsOneWidget);

        // Trigger dismiss in one direction (e.g., right)
        await tester.drag(dismissibleFinder, const Offset(1000, 0));
        await tester.pumpAndSettle();

        var cancelButtonFinder = find.widgetWithText(TextButton, 'Cancel');
        expect(cancelButtonFinder, findsOneWidget);
        await tester.tap(cancelButtonFinder);
        await tester.pumpAndSettle();

        expect(find.byType(CarouselCard), findsOneWidget);
        expect(find.text('Featured games'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);
        expect(find.text('Confirm'), findsNothing);

        await tester.drag(dismissibleFinder, const Offset(1000, 0));
        await tester.pumpAndSettle();

        var confirmButtonFinder = find.widgetWithText(ElevatedButton, 'Confirm');
        expect(confirmButtonFinder, findsOneWidget);
        await tester.tap(confirmButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Cancel'), findsNothing);
        expect(find.text('Confirm'), findsNothing);
        expect(find.text('Featured games'), findsNothing);
        expect(find.text('Subtitle'), findsNothing);

      });
    });
/*
    testWidgets('Notification Toggle Test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: ChangeNotifierProvider<PageProvider>(
              create: (_) => PageProvider(),
              child: CarouselCard(
                title: 'Featured Games',
                subtitle: 'Check out these awesome games!',
                items: [
                  getGame("Game 1"),
                  getGame("Game 2"),
                ],
                notify: false,
                onUpdateSavedSearches: (bool value) {},
              ),
            ),
          ),
        ));

        // Verifica se la notifica è abilitata di default
        expect(find.byIcon(Icons.notifications_none), findsOneWidget);

        // Tocca l'icona di notifica per disabilitarla
        await tester.tap(find.byIcon(Icons.notifications_none));
        await tester.pumpAndSettle();

        // Verifica se la notifica è stata disabilitata
        expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      });
    });
*/
    testWidgets('Carousel Scroll Test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: ChangeNotifierProvider<PageProvider>(
              create: (_) => PageProvider(),
              child: CarouselCard(
                title: 'Featured Games',
                subtitle: 'Check out these awesome games!',
                items: [
                  getGame("Game 1"),
                  getGame("Game 2"),
                ],
                notify: true,
                onUpdateSavedSearches: (bool value) {},
              ),
            ),
          ),
        ));

        // Verifica che la lista dei giochi sia inizialmente visibile
        expect(find.byType(ListView), findsOneWidget);

        final initialScrollOffset = tester.getTopLeft(find.byType(ListView)).dx;

        await tester.drag(find.byType(ListView), const Offset(-100, 0));
        await tester.pump();

        final newScrollOffset = tester.getTopLeft(find.byType(ListView)).dx;

        expect(newScrollOffset, lessThan(initialScrollOffset));
      });
    });


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
