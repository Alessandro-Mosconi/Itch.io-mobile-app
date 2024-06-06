// File: test/mocks.dart
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:itchio/providers/theme_notifier.dart';  // Adjust the path according to your project structure
import 'package:itchio/services/oauth_service.dart';

class MockThemeNotifier extends Mock implements ThemeNotifier {
  @override
  ThemeMode get themeMode => super.noSuchMethod(
      Invocation.getter(#themeMode),
      returnValue: ThemeMode.system,
      returnValueForMissingStub: ThemeMode.system);

  @override
  String get currentTheme => super.noSuchMethod(
      Invocation.getter(#currentTheme),
      returnValue: 'standard',
      returnValueForMissingStub: 'standard');

  @override
  void setThemeMode(ThemeMode mode) {
    super.noSuchMethod(
        Invocation.method(#setThemeMode, [mode]),
        returnValue: null,
        returnValueForMissingStub: null);
  }

  @override
  void setTheme(String theme) {
    super.noSuchMethod(
        Invocation.method(#setTheme, [theme]),
        returnValue: null,
        returnValueForMissingStub: null);
  }
}


class MockOAuthService extends Mock implements OAuthService {}

