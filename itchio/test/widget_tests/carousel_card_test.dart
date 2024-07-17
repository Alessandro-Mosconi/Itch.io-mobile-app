import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/search_bookmark_provider.dart';
import 'package:itchio/services/notification_service.dart';
import 'package:itchio/widgets/carousel_card.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mock_notification_service.mocks.dart';
import '../mock_page_provider.mocks.dart';
import '../mock_saved_searches_provider.mocks.dart';
import '../mock_search_bookmark_provider.mocks.dart';

void main() {
  group('CarouselCard Tests', () {

    final mockSavedSearchesProvider = MockSavedSearchesProvider();
    final mockNotificationService = MockNotificationService();
    final mockSearchBookMarkProvider = MockSearchBookmarkProvider();
    final mockPageProvider = MockPageProvider();


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
              ),
            ),
          ),
        ));

        expect(find.byType(CarouselCard), findsOneWidget);
        expect(find.text('Featured games'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
      });
    });
    testWidgets('Widget tap Test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: ChangeNotifierProvider<PageProvider>(
              create: (_) => mockPageProvider,
              child: CarouselCard(
                title: 'Featured Games',
                subtitle: 'Subtitle',
                items: [
                  getGame("Game 1"),
                  getGame("Game 2"),
                  getGame("Game 3"),
                  getGame("Game 4"),
                  getGame("Game 5"),
                  getGame("Game 6"),
                  getGame("Game 7"),
                  getGame("Game 8")
                ],
                notify: true,
              ),
            ),
          ),
        ));

        expect(find.text('Game 1'), findsOneWidget);
        await tester.tap(find.text('Game 1'));

        verify(mockPageProvider.setExtraPage(any)).called(1);
      });
    });
    testWidgets('Dismiss delete test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<PageProvider>(
                  create: (_) => PageProvider(),
                ),
                Provider<NotificationService>(
                  create: (_) => mockNotificationService,
                ),
                ChangeNotifierProvider<SavedSearchesProvider>(
                  create: (_) => mockSavedSearchesProvider,
                ),
                ChangeNotifierProvider<SearchBookmarkProvider>(
                  create: (_) => mockSearchBookMarkProvider,
                ),
              ],
              child: Scaffold(
                body: CarouselCard(
                  title: 'Featured Games',
                  subtitle: 'Subtitle',
                  items: [
                    getGame("Game 1"),
                    getGame("Game 2"),
                  ],
                  notify: true,
                ),
              ),
            ),
          ),
        ));

        final dismissibleFinder = find.byType(Dismissible);

        expect(dismissibleFinder, findsOneWidget);

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

        verify(mockSavedSearchesProvider.deleteSavedSearch(any, any)).called(1);

      });
    });
    testWidgets('Dismiss search test', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<PageProvider>(
                  create: (_) => mockPageProvider,
                ),
                Provider<NotificationService>(
                  create: (_) => mockNotificationService,
                ),
                ChangeNotifierProvider<SavedSearchesProvider>(
                  create: (_) => mockSavedSearchesProvider,
                ),
                ChangeNotifierProvider<SearchBookmarkProvider>(
                  create: (_) => mockSearchBookMarkProvider,
                ),
              ],
              child: CarouselCard(
                title: 'Featured Games',
                subtitle: 'Subtitle',
                items: [
                  getGame("Game 1"),
                  getGame("Game 2"),
                ],
                notify: true,
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

        verify(mockPageProvider.navigateToIndexWithPage(1, any)).called(1);

      });
    });

    testWidgets('Notification Toggle Test true', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PageProvider>(
                create: (_) => PageProvider(),
              ),
              Provider<NotificationService>(
                create: (_) => mockNotificationService,
              ),
              ChangeNotifierProvider<SavedSearchesProvider>(
                create: (_) => mockSavedSearchesProvider,
              ),
            ],
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.ltr,
                child: CarouselCard(
                  title: 'testTitle',
                  subtitle: 'testSubtitle',
                  items: [
                    getGame("Game 1"),
                    getGame("Game 2"),
                  ],
                  notify: false,
                ),
              ),
            ),
          ),
        );

        // Verifica se la notifica è abilitata di default
        expect(find.byIcon(Icons.notifications_none), findsOneWidget);

        // Tocca l'icona di notifica per disabilitarla
        await tester.tap(find.byIcon(Icons.notifications_none));
        await tester.pumpAndSettle();

        verify(mockNotificationService.subscribeToTopic(_generateTopicHash('testTitle','testSubtitle'))).called(1);
      });
    });

    testWidgets('Notification Toggle Test false', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PageProvider>(
                create: (_) => PageProvider(),
              ),
              Provider<NotificationService>(
                create: (_) => mockNotificationService,
              ),
              ChangeNotifierProvider<SavedSearchesProvider>(
                create: (_) => mockSavedSearchesProvider,
              ),
            ],
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.ltr,
                child: CarouselCard(
                  title: 'testTitle',
                  subtitle: 'testSubtitle',
                  items: [
                    getGame("Game 1"),
                    getGame("Game 2"),
                  ],
                  notify: true,
                ),
              ),
            ),
          ),
        );

        // Verifica se la notifica è abilitata di default
        expect(find.byIcon(Icons.notifications_active), findsOneWidget);

        // Tocca l'icona di notifica per disabilitarla
        await tester.tap(find.byIcon(Icons.notifications_active));
        await tester.pumpAndSettle();

        verify(mockNotificationService.unsubscribeFromTopic(_generateTopicHash('testTitle','testSubtitle'))).called(1);
      });
    });



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

String _generateTopicHash(String type, String filters) {
  String typeDefault = type;
  return sha256.convert(utf8.encode(typeDefault + filters)).toString(); // key
}