import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:itchio/views/settings_page.dart';
import 'package:itchio/services/oauth_service.dart';
import 'package:itchio/providers/theme_notifier.dart';

import '../mock_oauth_service.mocks.dart';
import '../mock_page_provider.mocks.dart';
import '../mock_theme_notifier.mocks.dart';

void main() {
  final MockThemeNotifier mockThemeNotifier = MockThemeNotifier();
  final MockOAuthService mockOAuthService = MockOAuthService();
  final MockPageProvider mockPageProvider = MockPageProvider();

  Widget createTestWidget() {
    when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
    when(mockThemeNotifier.currentTheme).thenReturn('standard');

    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
            ChangeNotifierProvider<OAuthService>(create: (_) => mockOAuthService),
            ChangeNotifierProvider<PageProvider>(create: (_) => mockPageProvider),
          ],
          child: SingleChildScrollView( // Wrap the content in a SingleChildScrollView
            child: ChangeNotifierProvider<PageProvider>(
              create: (_) => PageProvider(),
              child: const SettingsPage(),
            ),
          ),
        ),
      ),
    );
  }

  group('SettingsPage Tests', () {
    testWidgets('Settings page builds and displays essential UI components', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Interactions with theme mode radio buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('darkModeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('Ensure state is maintained when selecting themes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fluxokiThemeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setTheme('fluxoki')).called(1);
    });

    testWidgets('Response to logout tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      verify(mockOAuthService.logout()).called(1);
    });
  });
}
