import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/views/home_page.dart';
import 'package:provider/provider.dart';

import '../mock_search_bookmark_provider.mocks.dart';
import '../mocks.dart';

void main() {
  group('HomePage Tests', () {
    final mockFavoriteProvider = MockFavoriteProvider();
    final mockSearchBookmarkProvider = MockSearchBookmarkProvider();

    testWidgets('HomePage shows CircularProgressIndicator when data is loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => mockFavoriteProvider),
            ChangeNotifierProvider(create: (_) => mockSearchBookmarkProvider),
          ],
          child: MaterialApp(home: HomePage()),
        ),
      );

    });

  });
}