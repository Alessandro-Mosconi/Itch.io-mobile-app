import 'package:itchio/providers/favorite_provider.dart';
import 'package:itchio/services/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:itchio/services/oauth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
