import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:itchio/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_theme_notifier.mocks.dart';


void main() {
  group('CustomAppBar Tests', () {
    late MockThemeNotifier mockThemeNotifier;

    setUp(() {
      mockThemeNotifier = MockThemeNotifier();
      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.dark);

    });
    testWidgets('displays correct logo in dark mode', (WidgetTester tester) async {
      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.dark);

      String logoDarkMode = 'assets/logo-white-new.svg';

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => mockThemeNotifier,
            child: const Scaffold(
              appBar: CustomAppBar(),
            ),
          ),
        ),
      );

      final svgFinder = find.byKey(Key(logoDarkMode));
      expect(svgFinder, findsOneWidget);
    });

    testWidgets('displays correct logo in light mode', (WidgetTester tester) async {
      when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.light);

      String logoLightMode = 'assets/logo-black-new.svg';
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => mockThemeNotifier,
            child: const Scaffold(
              appBar: CustomAppBar(),
            ),
          ),
        ),
      );

      final svgFinder = find.byKey(Key(logoLightMode));
      expect(svgFinder, findsOneWidget);
    });

    testWidgets('displays actions and leading widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp( // Removed const from here
          home: ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => mockThemeNotifier,
            child: const Scaffold(
              appBar: CustomAppBar(
                actions: [Icon(Icons.search)],
                leading: Icon(Icons.menu),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });
  });
}