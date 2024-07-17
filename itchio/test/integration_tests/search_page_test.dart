import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/filter.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/item_type.dart';
import 'package:itchio/models/jam.dart';
import 'package:itchio/providers/filter_provider.dart';
import 'package:itchio/providers/item_type_provider.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/search_bookmark_provider.dart';
import 'package:itchio/providers/search_provider.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/views/search_page.dart';
import 'package:itchio/widgets/filter_popup.dart';
import 'package:itchio/widgets/game_card.dart';
import 'package:itchio/widgets/responsive_grid_list_game.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../mocks/mock_filter_provider.mocks.dart';
import '../mocks/mock_item_type_provider.mocks.dart';
import '../mocks/mock_saved_searches_provider.mocks.dart';
import '../mocks/mock_search_bookmark_provider.mocks.dart';
import '../mocks/mock_search_provider.mocks.dart';
import '../mocks/mock_theme_notifier.mocks.dart';

void main() {
  group('FavoritePage Tests', () {
    late MockFilterProvider mockFilterProvider;
    late MockThemeNotifier mockThemeNotifier;
    late MockSearchBookmarkProvider mockSearchBookmarkProvider;
    late MockItemTypeProvider mockItemTypeProvider;
    late MockSearchProvider mockSearchProvider;
    late MockSavedSearchesProvider mockSavedSearchesProvider;

    setUp(() {
      mockFilterProvider = MockFilterProvider();
      mockThemeNotifier = MockThemeNotifier();
      mockSearchBookmarkProvider = MockSearchBookmarkProvider();
      mockItemTypeProvider = MockItemTypeProvider();
      mockSearchProvider = MockSearchProvider();
      mockSavedSearchesProvider = MockSavedSearchesProvider();

      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
      when(mockThemeNotifier.currentTheme).thenReturn('standard');

      when(mockItemTypeProvider.fetchTabs()).thenAnswer((_) async => [ItemType({'name': 'games', 'label': 'Games'})]);

      when(mockSearchProvider.fetchTabResults(any, any)).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 1));
        return {
          'items': [],
          'title': "Title - itch.io",
        };
      });

      when(mockSearchProvider.fetchSearchResults(any)).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 1));
        return {
          'games': [getGame("Game title 1").toMap()],
          'users': [],
        };
      });

      when(mockFilterProvider.fetchFilters()).thenAnswer((_) async {
        return getFiltersExample();
      });

      when(mockSearchBookmarkProvider.isSearchBookmarked(any, any)).thenReturn(false);

      when(mockSearchBookmarkProvider.fetchBookmarks()).thenAnswer((_) async {
        return [];
      });
    });

    testWidgets('SearchPage Open filter', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );

        //find and tab filter icon
        final Finder filterIconFinder = find.byIcon(Icons.filter_list);
        expect(filterIconFinder, findsOneWidget);
        await tester.tap(filterIconFinder);
        await tester.pumpAndSettle();

        expect(find.byType(FilterPopup), findsOne);

        final Finder confirmButtonFinder = find.text('Confirm');
        await tester.tap(confirmButtonFinder);
        await tester.pumpAndSettle();

        expect(find.byType(FilterPopup), findsNothing);

      });

    });

    testWidgets('SearchPage Empty messages', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );


        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.pumpAndSettle();

        expect(find.text('Games'), findsOne);
        expect(find.text('No results found'), findsOne);

      });

    });

    testWidgets('SearchPage with parameters', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage(initialTab: 'game', initialFilters: '/accessibility-colorblind/duration-seconds')),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.widgetWithText(badges.Badge, "2"), findsOneWidget);

      });

    });

    testWidgets('SearchPage tap on tab', (WidgetTester tester) async {

      when(mockItemTypeProvider.fetchTabs()).thenAnswer((_) async => [
        ItemType({'name': 'games', 'label': 'Games'}),
        ItemType({'name': 'assets', 'label': 'Assets'})]
      );


      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage(initialTab: 'assets', initialFilters: '/accessibility-colorblind/duration-seconds')),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Assets'), findsOne);
        expect(find.text('Games'), findsOne);

      });

    });

    testWidgets('SearchPage Refresh', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );

        await tester.pumpAndSettle();

        final Finder refreshIndicatorFinder = find.byType(RefreshIndicator);

        expect(refreshIndicatorFinder, findsOneWidget);

        await tester.runAsync(() => (refreshIndicatorFinder.evaluate().first.widget as RefreshIndicator).onRefresh());

        for (int i = 0; i < 5; i++) {
          await tester.pump(Duration(seconds: 1));
        }

        await tester.pumpAndSettle();

        verify(mockSearchProvider.reloadSearchProvider()).called(1);

      });

    });

    testWidgets('SearchPage Not empty messages', (WidgetTester tester) async {

      when(mockSearchProvider.fetchTabResults(any, any)).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 1));
        return {
          'items': [getGame("game1").toMap()],
          'title': "Title - itch.io",
        };
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );


        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.pumpAndSettle();

        expect(find.text('Games'), findsOne);
        expect(find.text('Title'), findsOne);
        expect(find.byType(GameCard), findsOne);

      });

    });

    testWidgets('SearchPage Save Search', (WidgetTester tester) async {

      when(mockSearchProvider.fetchTabResults(any, any)).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 1));
        return {
          'items': [getGame("game1").toMap()],
          'title': "Title - itch.io",
        };
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );

        await tester.pumpAndSettle();

        final Finder bookmarkIconFinder = find.byIcon(Icons.bookmark_border);
        expect(bookmarkIconFinder, findsOneWidget);
        await tester.tap(bookmarkIconFinder);

        verify(mockSearchBookmarkProvider.addSearchBookmark(any, any)).called(1);

      });

      when(mockSearchBookmarkProvider.isSearchBookmarked(any, any)).thenReturn(true);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier)
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );

        await tester.pumpAndSettle();

        final Finder bookmarkIconFinder = find.byIcon(Icons.bookmark);
        expect(bookmarkIconFinder, findsOneWidget);
        await tester.tap(bookmarkIconFinder);

        verify(mockSearchBookmarkProvider.removeSearchBookmark(any, any)).called(1);
      });

    });

    testWidgets('SearchPage Search element', (WidgetTester tester) async {

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FilterProvider>(create: (_) => mockFilterProvider),
              ChangeNotifierProvider<SearchBookmarkProvider>(create: (_) => mockSearchBookmarkProvider),
              ChangeNotifierProvider<ItemTypeProvider>(create: (_) => mockItemTypeProvider),
              ChangeNotifierProvider<SearchProvider>(create: (_) => mockSearchProvider),
              ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
              ChangeNotifierProvider<SavedSearchesProvider>(create: (_) => mockSavedSearchesProvider)
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test');

        await tester.tap(find.byIcon(Icons.search));

        verify(mockSearchProvider.fetchSearchResults('test')).called(1);

        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.pumpAndSettle();

        expect(find.byType(ResponsiveGridListGame), findsOne);
        expect(find.byType(GameCard), findsOne);
        expect(find.text('Game title 1'), findsOne);


        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        expect(find.byType(ResponsiveGridListGame), findsNothing);
        expect(find.byType(GameCard), findsNothing);

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


List<Filter> getFiltersExample() {

  const String jsonStringFilters = '''[
   {
      "name":"accessibility",
      "label":"Accessibility",
      "isAlternative":false,
      "options":[
         {
            "name":"accessibility-colorblind",
            "label":"Colorblind",
            "isSelected":false
         },
         {
            "name":"accessibility-subtitles",
            "label":"Subtitles",
            "isSelected":false
         },
         {
            "name":"accessibility-configurable-controls",
            "label":"Configurable Controls",
            "isSelected":false
         },
         {
            "name":"accessibility-highcontrast",
            "label":"High Contrast",
            "isSelected":false
         },
         {
            "name":"accessibility-tutorial",
            "label":"Tutorial",
            "isSelected":false
         },
         {
            "name":"accessibility-one-button",
            "label":"One Button",
            "isSelected":false
         },
         {
            "name":"accessibility-blind",
            "label":"Blind",
            "isSelected":false
         },
         {
            "name":"accessibility-textless",
            "label":"Textless",
            "isSelected":false
         }
      ]
   },
   {
      "name":"avg_session_length",
      "label":"Average Session Length",
      "isAlternative":true,
      "options":[
         {
            "name":"duration-seconds",
            "label":"Seconds",
            "isSelected":false
         },
         {
            "name":"duration-minutes",
            "label":"Minutes",
            "isSelected":false
         },
         {
            "name":"duration-half-hour",
            "label":"Half Hour",
            "isSelected":false
         },
         {
            "name":"duration-hour",
            "label":"Hour",
            "isSelected":false
         },
         {
            "name":"duration-hours",
            "label":"Hours",
            "isSelected":false
         },
         {
            "name":"duration-days",
            "label":"Days",
            "isSelected":false
         }
      ]
   },
   {
      "name":"genre",
      "label":"Genre",
      "isAlternative":false,
      "options":[
         {
            "name":"genre-action",
            "label":"Action",
            "isSelected":false
         },
         {
            "name":"genre-adventure",
            "label":"Adventure",
            "isSelected":false
         },
         {
            "name":"tag-card-game",
            "label":"Card Game",
            "isSelected":false
         },
         {
            "name":"tag-survival",
            "label":"Survival",
            "isSelected":false
         },
         {
            "name":"tag-educational",
            "label":"Educational",
            "isSelected":false
         },
         {
            "name":"tag-fighting",
            "label":"Fighting",
            "isSelected":false
         },
         {
            "name":"tag-interactive-fiction",
            "label":"Interactive Fiction",
            "isSelected":false
         },
         {
            "name":"genre-platformer",
            "label":"Platformer",
            "isSelected":false
         },
         {
            "name":"genre-puzzle",
            "label":"Puzzle",
            "isSelected":false
         },
         {
            "name":"tag-racing",
            "label":"Racing",
            "isSelected":false
         },
         {
            "name":"tag-rhythm",
            "label":"Rhythm",
            "isSelected":false
         },
         {
            "name":"genre-rpg",
            "label":"RPG",
            "isSelected":false
         },
         {
            "name":"genre-shooter",
            "label":"Shooter",
            "isSelected":false
         },
         {
            "name":"genre-simulation",
            "label":"Simulation",
            "isSelected":false
         },
         {
            "name":"genre-strategy",
            "label":"Strategy",
            "isSelected":false
         },
         {
            "name":"genre-other",
            "label":"Other",
            "isSelected":false
         },
         {
            "name":"genre-visual-novel",
            "label":"Visual Novel",
            "isSelected":false
         }
      ]
   }
]
  ''';

  List<dynamic> jsonFilters = json.decode(jsonStringFilters);

  List<Filter> filters = jsonFilters.map((f) => Filter(f)).toList();

  return filters;
}

List<Filter> getFiltersSelectedExample() {

  const String jsonStringFilters = '''[
   {
      "name":"accessibility",
      "label":"Accessibility",
      "isAlternative":false,
      "options":[
         {
            "name":"accessibility-colorblind",
            "label":"Colorblind",
            "isSelected":true
         },
         {
            "name":"accessibility-subtitles",
            "label":"Subtitles",
            "isSelected":false
         },
         {
            "name":"accessibility-configurable-controls",
            "label":"Configurable Controls",
            "isSelected":false
         },
         {
            "name":"accessibility-highcontrast",
            "label":"High Contrast",
            "isSelected":false
         },
         {
            "name":"accessibility-tutorial",
            "label":"Tutorial",
            "isSelected":false
         },
         {
            "name":"accessibility-one-button",
            "label":"One Button",
            "isSelected":false
         },
         {
            "name":"accessibility-blind",
            "label":"Blind",
            "isSelected":false
         },
         {
            "name":"accessibility-textless",
            "label":"Textless",
            "isSelected":false
         }
      ]
   },
   {
      "name":"avg_session_length",
      "label":"Average Session Length",
      "isAlternative":true,
      "options":[
         {
            "name":"duration-seconds",
            "label":"Seconds",
            "isSelected":true
         },
         {
            "name":"duration-minutes",
            "label":"Minutes",
            "isSelected":false
         },
         {
            "name":"duration-half-hour",
            "label":"Half Hour",
            "isSelected":false
         },
         {
            "name":"duration-hour",
            "label":"Hour",
            "isSelected":false
         },
         {
            "name":"duration-hours",
            "label":"Hours",
            "isSelected":false
         },
         {
            "name":"duration-days",
            "label":"Days",
            "isSelected":false
         }
      ]
   },
   {
      "name":"genre",
      "label":"Genre",
      "isAlternative":false,
      "options":[
         {
            "name":"genre-action",
            "label":"Action",
            "isSelected":false
         },
         {
            "name":"genre-adventure",
            "label":"Adventure",
            "isSelected":false
         },
         {
            "name":"tag-card-game",
            "label":"Card Game",
            "isSelected":false
         },
         {
            "name":"tag-survival",
            "label":"Survival",
            "isSelected":false
         },
         {
            "name":"tag-educational",
            "label":"Educational",
            "isSelected":false
         },
         {
            "name":"tag-fighting",
            "label":"Fighting",
            "isSelected":false
         },
         {
            "name":"tag-interactive-fiction",
            "label":"Interactive Fiction",
            "isSelected":false
         },
         {
            "name":"genre-platformer",
            "label":"Platformer",
            "isSelected":false
         },
         {
            "name":"genre-puzzle",
            "label":"Puzzle",
            "isSelected":false
         },
         {
            "name":"tag-racing",
            "label":"Racing",
            "isSelected":false
         },
         {
            "name":"tag-rhythm",
            "label":"Rhythm",
            "isSelected":false
         },
         {
            "name":"genre-rpg",
            "label":"RPG",
            "isSelected":false
         },
         {
            "name":"genre-shooter",
            "label":"Shooter",
            "isSelected":false
         },
         {
            "name":"genre-simulation",
            "label":"Simulation",
            "isSelected":false
         },
         {
            "name":"genre-strategy",
            "label":"Strategy",
            "isSelected":false
         },
         {
            "name":"genre-other",
            "label":"Other",
            "isSelected":false
         },
         {
            "name":"genre-visual-novel",
            "label":"Visual Novel",
            "isSelected":false
         }
      ]
   }
]
  ''';

  List<dynamic> jsonFilters = json.decode(jsonStringFilters);

  List<Filter> filters = jsonFilters.map((f) => Filter(f)).toList();

  return filters;
}

