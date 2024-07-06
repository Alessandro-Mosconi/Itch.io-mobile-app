// File: test/unit_tests/oauth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:itchio/services/oauth_service.dart';
import 'dart:async';
// import url_launcher
// Ensure WidgetsFlutterBinding is available
import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OAuthService', () {
    late OAuthService oauthService;
    late MockSharedPreferences mockSharedPreferences;
    late MockLogger mockLogger;

    late GetInitialLink mockGetInitialLink;
    late LinkStream mockLinkStream;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockLogger = MockLogger();
      mockGetInitialLink = () async => 'itchio-app://oauth-callback#access_token=test_token';
      mockLinkStream = () => Stream<String?>.fromIterable(['itchio-app://oauth-callback#access_token=test_token']);

      oauthService = OAuthService(
        sharedPreferences: mockSharedPreferences,
        customLogger: mockLogger,
        getInitialLink: mockGetInitialLink,
        linkStream: mockLinkStream,
      );
    });

    test('initSharedPreferences loads access token', () async {
      when(mockSharedPreferences.getString("")).thenReturn('test_token');

      await oauthService.initSharedPreferences();

      expect(oauthService.accessToken, 'test_token');
    });

    test('initUniLinks sets up initial link and stream subscription', () async {
      await oauthService.initUniLinks();
      expect(oauthService.accessToken, 'test_token');
    });

    test('handleLink extracts and handles access token', () {
      const testLink = 'itchio-app://oauth-callback#access_token=test_token';

      oauthService.handleLink(testLink);
      expect(oauthService.accessToken, 'test_token');
    });

    test('handleAccessToken saves access token and notifies listeners', () async {
      const accessToken = 'test_token';
      when(mockSharedPreferences.setString("","")).thenAnswer((_) async => true);

      oauthService.handleAccessToken(accessToken);

      verify(mockSharedPreferences.setString('access_token', accessToken)).called(1);
      expect(oauthService.accessToken, accessToken);
    });

    test('logout clears access token and notifies listeners', () async {
      when(mockSharedPreferences.remove("")).thenAnswer((_) async => true);

      oauthService.handleAccessToken('test_token');
      oauthService.logout();

      verify(mockSharedPreferences.remove('access_token')).called(1);
      expect(oauthService.accessToken, isNull);
    });
  });
}
