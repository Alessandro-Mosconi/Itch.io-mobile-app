import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/providers/theme_notifier.dart';

void main() {
  group('ThemeNotifier', () {
    late ThemeNotifier themeNotifier;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();  // Ensure widget bindings are initialized
      themeNotifier = ThemeNotifier();
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
