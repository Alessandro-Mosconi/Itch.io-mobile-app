import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:itchio/views/settings_page.dart';
import 'package:itchio/services/oauth_service.dart';
import 'package:itchio/providers/theme_notifier.dart';
import '../mocks.dart';

void main() {
  // Define mocks at the top of the main function to ensure they are accessible in all test cases
  final MockThemeNotifier mockThemeNotifier = MockThemeNotifier();
  final MockOAuthService mockOAuthService = MockOAuthService();

  Widget createTestWidget(Widget child) {
    // Use the already defined mocks
    when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
    when(mockThemeNotifier.currentTheme).thenReturn('standard');

    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>(create: (_) => mockThemeNotifier),
          ChangeNotifierProvider<OAuthService>(create: (_) => mockOAuthService),
        ],
        child: child,
      ),
    );
  }

  group('SettingsPage Tests', () {
    testWidgets('Settings page builds and displays essential UI components', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsPage()));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Interactions with theme mode radio buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('darkModeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('Ensure state is maintained when selecting themes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fluxokiThemeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setTheme('fluxoki')).called(1);
    });

    testWidgets('Response to logout tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      verify(mockOAuthService.logout()).called(1);
    });


  });
}
