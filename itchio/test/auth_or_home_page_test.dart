import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:itchio/auth_page.dart';
import 'package:itchio/home_page.dart';
import 'package:itchio/oauth_service.dart';
import 'package:itchio/main.dart';

class MockOAuthService extends Mock implements OAuthService {}

void main() {
  testWidgets('AuthOrHomePage shows AuthPage when not authenticated', (WidgetTester tester) async {
    // Arrange
    final mockOAuthService = MockOAuthService();
    when(mockOAuthService.accessToken).thenReturn(null);

    // Act
    await tester.pumpWidget(
      ChangeNotifierProvider<OAuthService>.value(
        value: mockOAuthService,
        child: MaterialApp(
          home: AuthOrHomePage(),
        ),
      ),
    );

    // Assert
    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(MyHomePage), findsNothing);
  });

  testWidgets('AuthOrHomePage shows MyHomePage when authenticated', (WidgetTester tester) async {
    // Arrange
    final mockOAuthService = MockOAuthService();
    when(mockOAuthService.accessToken).thenReturn('dummy_access_token');

    // Act
    await tester.pumpWidget(
      ChangeNotifierProvider<OAuthService>.value(
        value: mockOAuthService,
        child: MaterialApp(
          home: AuthOrHomePage(),
        ),
      ),
    );

    // Assert
    expect(find.byType(AuthPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });
}
