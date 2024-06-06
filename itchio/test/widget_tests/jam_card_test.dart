import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;

import 'package:itchio/main.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:itchio/views/game_webview_page.dart';
import 'package:itchio/widgets/jam_card.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

void main() {
  final Logger logger = Logger(printer: PrettyPrinter());
  testWidgets('Jam card test', (WidgetTester tester) async {
    // Costruisci il widget da testare.
    Jam jam = getJamExample();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: ChangeNotifierProvider<PageProvider>(
            create: (_) => PageProvider(), // Fornisci il provider PageProvider
            child: JamCard(jam: jam, isTablet: false),
          ),
        ),
      ),
    );

    expect(find.text(jam.title!), findsOneWidget);
    expect(find.text("Participants: ${jam.joined}"), findsOneWidget);
    expect(find.text("Start: ${intl.DateFormat('dd MMM yyyy').format(jam.startDate!)}"), findsOneWidget);
    expect(find.text("End: ${intl.DateFormat('dd MMM yyyy').format(jam.endDate!)}"), findsOneWidget);
    expect(find.text("Voting Ends: ${jam.votingEndDate == null ? 'null' : intl.DateFormat('dd MMM yyyy').format(jam.votingEndDate!)}"), findsOneWidget);

    final Finder buttonFinder = find.byIcon(Icons.calendar_today);

    await tester.tap(buttonFinder);

    await tester.pump();

    expect(find.text('Choose the event to save'), findsOneWidget);
    expect(find.text("Voting end:\n${_formatDate(jam.votingEndDate)}"), findsOneWidget);

    final durationButtonFinder = find.widgetWithText(ElevatedButton, "Jam duration:\n${_formatDate(jam.startDate)}\n${_formatDate(jam.endDate)}");
    expect(durationButtonFinder, findsOneWidget);
    await tester.tap(durationButtonFinder);

    await tester.pumpAndSettle();

    final durationButtonFinderAfter = find.widgetWithText(ElevatedButton, "Jam duration:\n${_formatDate(jam.startDate)}\n${_formatDate(jam.endDate)}");
    expect(durationButtonFinderAfter, findsNothing);

    final Finder buttonFinder2 = find.byIcon(Icons.calendar_today);

    await tester.tap(buttonFinder2);

    await tester.pump();

    final votingEndButtonFinder = find.widgetWithText(ElevatedButton, "Voting end:\n${_formatDate(jam.votingEndDate)}");
    expect(votingEndButtonFinder, findsOneWidget);

    await tester.tap(votingEndButtonFinder);

    await tester.pumpAndSettle();

    final votingEndButtonFinderAfter = find.widgetWithText(ElevatedButton, "Voting end:\n${_formatDate(jam.votingEndDate)}");
    expect(votingEndButtonFinderAfter, findsNothing);

    await tester.tap(find.byKey(Key('jam_card_gesture_detector')));

    await tester.pumpAndSettle();
    //TODO da verificare davvero
    //expect(find.byType(GameWebViewPage), findsOneWidget);

  });

  testWidgets('Jam card tablet test', (WidgetTester tester) async {

    //TEST JAM VIEW

    Jam jam = getJamExample();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: ChangeNotifierProvider<PageProvider>(
            create: (_) => PageProvider(), // Fornisci il provider PageProvider
            child: JamCard(jam: jam, isTablet: true),
          ),
        ),
      ),
    );

    expect(find.text(jam.title!), findsOneWidget);
    expect(find.text("Participants: ${jam.joined}"), findsOneWidget);
    expect(find.text("Start: ${intl.DateFormat('dd MMM yyyy').format(jam.startDate!)}"), findsOneWidget);
    expect(find.text("End: ${intl.DateFormat('dd MMM yyyy').format(jam.endDate!)}"), findsOneWidget);
    expect(find.text("Voting Ends: ${jam.votingEndDate == null ? 'null' : intl.DateFormat('dd MMM yyyy').format(jam.votingEndDate!)}"), findsOneWidget);


    //TEST TAP ON CALENDAR

    final Finder buttonFinder = find.byIcon(Icons.calendar_today);

    await tester.tap(buttonFinder);

    await tester.pump();

    expect(find.text('Choose the event to save'), findsOneWidget);
    expect(find.text("Voting end:\n${_formatDate(jam.votingEndDate)}"), findsOneWidget);

    final durationButtonFinder = find.widgetWithText(ElevatedButton, "Jam duration:\n${_formatDate(jam.startDate)}\n${_formatDate(jam.endDate)}");
    expect(durationButtonFinder, findsOneWidget);
    await tester.tap(durationButtonFinder);

    await tester.pumpAndSettle();

    final durationButtonFinderAfter = find.widgetWithText(ElevatedButton, "Jam duration:\n${_formatDate(jam.startDate)}\n${_formatDate(jam.endDate)}");
    expect(durationButtonFinderAfter, findsNothing);

    final Finder buttonFinder2 = find.byIcon(Icons.calendar_today);

    await tester.tap(buttonFinder2);

    await tester.pump();

    final votingEndButtonFinder = find.widgetWithText(ElevatedButton, "Voting end:\n${_formatDate(jam.votingEndDate)}");
    expect(votingEndButtonFinder, findsOneWidget);

    await tester.tap(votingEndButtonFinder);

    await tester.pumpAndSettle();

    final votingEndButtonFinderAfter = find.widgetWithText(ElevatedButton, "Voting end:\n${_formatDate(jam.votingEndDate)}");
    expect(votingEndButtonFinderAfter, findsNothing);

    final Finder buttonFinder3 = find.byIcon(Icons.calendar_today);

    await tester.tap(buttonFinder3);

    await tester.pump();

    final cancelButton = find.widgetWithText(TextButton, "Cancel");

    await tester.tap(cancelButton);

    await tester.pump();

    expect(cancelButton, findsNothing);

    //TEST TAP ON JAM

    await tester.tap(find.byKey(Key('jam_card_gesture_detector')));

    await tester.pumpAndSettle();
    //TODO da verificare davvero
    //expect(find.byType(GameWebViewPage), findsOneWidget);

  });

  testWidgets('Jam card test with voting end null', (WidgetTester tester) async {
    // Costruisci il widget da testare.
    Jam jam = getJamExample();
    jam.votingEndDate = null;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: JamCard(jam: jam, isTablet: false),
        ),
      ),
    );

    expect(find.text(jam.title!), findsOneWidget);
    expect(find.text("Participants: ${jam.joined}"), findsOneWidget);
    expect(find.text("Start: ${intl.DateFormat('dd MMM yyyy').format(jam.startDate!)}"), findsOneWidget);
    expect(find.text("End: ${intl.DateFormat('dd MMM yyyy').format(jam.endDate!)}"), findsOneWidget);
    expect(find.text("Voting Ends: ${jam.votingEndDate == null ? 'null' : intl.DateFormat('dd MMM yyyy').format(jam.votingEndDate!)}"), findsOneWidget);

    final Finder buttonFinder = find.byIcon(Icons.calendar_today);

    await tester.tap(buttonFinder);

    await tester.pump();

    expect(find.text('Choose the event to save'), findsOneWidget);
    expect(find.text("Voting end:\n${_formatDate(jam.votingEndDate)}"), findsNothing);

  });
}

String _formatDate(DateTime? date) {
  return date != null ? intl.DateFormat('dd/MM/yyyy HH:mm').format(date) : 'n/a';
}

Jam getJamExample() {
  Map<String, dynamic> userData = getUser();

  // Dati per il gioco
  Map<String, dynamic> gameData = getGame(userData);
  Map<String, dynamic> jamGameData = getJamGame(gameData);

  // Dati per la Jam
  Map<String, dynamic> jamData = {
    'hue': 120,
    'start_date': '2023-01-01T00:00:00Z',
    'end_date': '2023-01-10T00:00:00Z',
    'voting_end_date': '2023-01-15T00:00:00Z',
    'featured': 1,
    'id': 1,
    'title': 'Sample Jam',
    'highlight': true,
    'joined': 100,
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

Map<String, dynamic> getGame(Map<String, dynamic> userData) {
  Map<String, dynamic> gameData = {
    'views_count': 100,
    'url': 'http://example.com/game/1',
    'id': 1,
    'short_text': 'Short description of the game',
    'min_price': 0,
    'price': 0.0,
    'type': 'action',
    'p_windows': true,
    'p_linux': false,
    'p_osx': false,
    'p_android': false,
    'title': 'Sample Game',
    'published_at': '2023-01-01T00:00:00Z',
    'can_be_bought': true,
    'classification': 'indie',
    'created_at': '2023-01-01T00:00:00Z',
    'in_press_system': false,
    'cover_url': 'https://flowbite.com/docs/images/examples/image-1@2x.jpg',
    'purchases_count': 50,
    'published': true,
    'downloads_count': 200,
    'has_demo': 'No',
    'user': userData,
    'still_cover_url': 'https://flowbite.com/docs/images/examples/image-1@2x.jpg',
    'description': 'Description of the game <img src="http://example.com/image.png">',
    'imageurl': 'https://flowbite.com/docs/images/examples/image-1@2x.jpg',
    'author': 'Example Author',
    'currency': 'USD',
  };
  return gameData;
}

Map<String, dynamic> getUser() {
  Map<String, dynamic> userData = {
    'username': 'example_user',
    'url': 'http://example.com/user/1',
    'id': 1,
    'display_name': 'Example User',
    'cover_url': 'https://flowbite.com/docs/images/examples/image-1@2x.jpg',
    'gamer': true,
    'developer': false,
    'img': 'https://flowbite.com/docs/images/examples/image-1@2x.jpg',
    'number_of_projects': "5",
  };
  return userData;
}
