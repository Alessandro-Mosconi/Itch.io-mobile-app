import 'package:itchio/providers/favorite_provider.dart';
import 'package:itchio/services/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:itchio/providers/theme_notifier.dart';  // Adjust the path according to your project structure
import 'package:itchio/services/oauth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
class MockFavoriteProvider extends Mock implements FavoriteProvider {}
class MockNotificationService extends Mock implements NotificationService {}

class MockSharedPreferences extends Mock implements SharedPreferences {
  @override
  Future<bool> setString(String key, String value) =>
      super.noSuchMethod(Invocation.method(#setString, [key, value]),
          returnValue: Future.value(true),
          returnValueForMissingStub: Future.value(true));

  @override
  String? getString(String key) =>
      super.noSuchMethod(Invocation.method(#getString, [key]),
          returnValue: 'test_token',
          returnValueForMissingStub: 'test_token');

  @override
  Future<bool> remove(String key) =>
      super.noSuchMethod(Invocation.method(#remove, [key]),
          returnValue: Future.value(true),
          returnValueForMissingStub: Future.value(true));
}

class MockLogger extends Mock implements Logger {}
