import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/widgets/search_bar.dart' as custom;
import 'package:mockito/mockito.dart';

class MockCallbacks extends Mock {
  void onSearch();
  void onClear();
  void onFilter();
  void onSaveSearch();
}

void main() {
  testWidgets('SearchBar widget test', (WidgetTester tester) async {
    final mockCallbacks = MockCallbacks();
    final searchController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: custom.SearchBar(
            searchController: searchController,
            showSaveButton: true,
            filterCount: 2,
            isBookmarked: true,
            onSearch: mockCallbacks.onSearch,
            onClear: mockCallbacks.onClear,
            onFilter: mockCallbacks.onFilter,
            onSaveSearch: mockCallbacks.onSaveSearch,
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);

    expect(find.byIcon(Icons.search), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    verify(mockCallbacks.onSearch()).called(1);

    await tester.enterText(find.byType(TextField), 'test search');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    verify(mockCallbacks.onSearch()).called(1);

    expect(find.byIcon(Icons.filter_list), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pump();
    verify(mockCallbacks.onFilter()).called(1);

    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pump();
    verify(mockCallbacks.onSaveSearch()).called(1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: custom.SearchBar(
            searchController: searchController,
            showSaveButton: true,
            filterCount: 2,
            isBookmarked: false,
            onSearch: mockCallbacks.onSearch,
            onClear: mockCallbacks.onClear,
            onFilter: mockCallbacks.onFilter,
            onSaveSearch: mockCallbacks.onSaveSearch,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();
    verify(mockCallbacks.onSaveSearch()).called(1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: custom.SearchBar(
            searchController: searchController,
            showSaveButton: false,
            filterCount: 2,
            isBookmarked: false,
            onSearch: mockCallbacks.onSearch,
            onClear: mockCallbacks.onClear,
            onFilter: mockCallbacks.onFilter,
            onSaveSearch: mockCallbacks.onSaveSearch,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.clear), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    verify(mockCallbacks.onClear()).called(1);
  });
}