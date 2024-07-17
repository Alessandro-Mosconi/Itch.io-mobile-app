import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/providers/theme_notifier.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_shared_preferences.mocks.dart';

void main() {
  group('ThemeNotifier', () {
    late ThemeNotifier themeNotifier;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      // get the mock of shared pref


      themeNotifier = ThemeNotifier();
      MockSharedPreferences mockPrefs = MockSharedPreferences();

      when(mockPrefs.getString('theme')).thenReturn('system');
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.getInt('themeMode')).thenReturn(ThemeMode.dark.index);

      themeNotifier.prefs = mockPrefs;

      themeNotifier.init();


    });

    tearDown(() {
      themeNotifier.dispose();
    });

    test('notifyListeners is called when setting a new theme', () {

      bool isNotified = false;
      themeNotifier.addListener(() {
        isNotified = true;
      });

      themeNotifier.setTheme('fluxoki');
      expect(isNotified, isTrue);
    });

    test('notifyListeners is called when setting a new theme mode', () {
      bool isNotified = false;
      themeNotifier.addListener(() {
        isNotified = true;
      });

      themeNotifier.setThemeMode(ThemeMode.dark);
      expect(isNotified, isTrue);
    });

  });
}
