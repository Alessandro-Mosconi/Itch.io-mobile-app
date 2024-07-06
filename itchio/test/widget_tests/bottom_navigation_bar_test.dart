import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/widgets/bottom_navigation_bar.dart';

void main() {
  testWidgets('MyBottomNavigationBar constructs correctly', (WidgetTester tester) async {
    onTapMock(int index) {}

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: 0,
            onTap: onTapMock,
          ),
        ),
      ),
    );

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('MyBottomNavigationBar has correct items', (WidgetTester tester) async {
    onTapMock(int index) {}

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: 0,
            onTap: onTapMock,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Jams'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('MyBottomNavigationBar sets currentIndex correctly', (WidgetTester tester) async {
    onTapMock(int index) {}

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: 2,
            onTap: onTapMock,
          ),
        ),
      ),
    );

    final bottomNavigationBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNavigationBar.currentIndex, 2);
  });

  testWidgets('MyBottomNavigationBar uses correct color scheme', (WidgetTester tester) async {
    onTapMock(int index) {}

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onSurface: Colors.grey,
          ),
        ),
        home: Scaffold(
          bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: 0,
            onTap: onTapMock,
          ),
        ),
      ),
    );

    final bottomNavigationBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNavigationBar.selectedItemColor, Colors.blue);
    expect(bottomNavigationBar.unselectedItemColor, Colors.grey);
  });

  testWidgets('MyBottomNavigationBar onTap callback works', (WidgetTester tester) async {
    int tappedIndex = -1;
    onTapMock(int index) {
      tappedIndex = index;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: 0,
            onTap: onTapMock,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Search'));
    expect(tappedIndex, 1);
  });
}
