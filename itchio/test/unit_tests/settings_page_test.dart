import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/providers/page_provider.dart';
import 'package:logger/logger.dart';
import 'package:network_image_mock/network_image_mock.dart';
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
  final Logger logger = Logger(printer: PrettyPrinter());


  Widget createTestWidget() {
    when(mockThemeNotifier.themeMode).thenReturn(ThemeMode.system);
    when(mockThemeNotifier.currentTheme).thenReturn('standard');
    when(mockOAuthService.onAuthenticationSuccess).thenAnswer((_) => Stream.value(true));
    when(mockPageProvider.currentExtraPage).thenReturn(Scaffold());
    when(mockPageProvider.selectedIndex).thenReturn(0);


    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>(
              create: (_) => mockThemeNotifier
          ),
          ChangeNotifierProvider<PageProvider>(
              create: (_) => mockPageProvider
          ),
          ChangeNotifierProvider<OAuthService>(
              create: (_) => mockOAuthService
          )
        ],
        child: const MaterialApp(home: SettingsPage()));
  }
  Widget createTestWidgetCustomTheme(ThemeMode thememode, String theme) {
    when(mockThemeNotifier.themeMode).thenReturn(thememode);
    when(mockThemeNotifier.currentTheme).thenReturn(theme);
    when(mockOAuthService.onAuthenticationSuccess).thenAnswer((_) => Stream.value(true));
    when(mockPageProvider.currentExtraPage).thenReturn(Scaffold());
    when(mockPageProvider.selectedIndex).thenReturn(0);


    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>(
              create: (_) => mockThemeNotifier
          ),
          ChangeNotifierProvider<PageProvider>(
              create: (_) => mockPageProvider
          ),
          ChangeNotifierProvider<OAuthService>(
              create: (_) => mockOAuthService
          )
        ],
        child: const MaterialApp(home: SettingsPage()));
  }

  group('SettingsPage Tests', () {
    testWidgets('Settings page builds and displays essential UI components', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);
      });
    });

    testWidgets('Interactions with theme mode radio buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('darkModeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setThemeMode(ThemeMode.dark)).called(1);

      await tester.tap(find.byKey(const Key('lightModeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setThemeMode(ThemeMode.light)).called(1);

      await tester.pumpWidget(createTestWidgetCustomTheme(ThemeMode.dark, 'fluxoki'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('systemThemeRadio')));
      await tester.pump();
      verify(mockThemeNotifier.setThemeMode(ThemeMode.system)).called(1);

    });

    testWidgets('Ensure state is maintained when selecting themes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fluxokiThemeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setTheme('fluxoki')).called(1);

      await tester.tap(find.byKey(const Key('abyssThemeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setTheme('abyss')).called(1);

      await tester.tap(find.byKey(const Key('vibrantThemeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setTheme('vibrant')).called(1);


      await tester.pumpWidget(createTestWidgetCustomTheme(ThemeMode.dark, 'fluxoki'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('standardThemeRadio')));
      await tester.pump();

      verify(mockThemeNotifier.setTheme('standard')).called(1);
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
