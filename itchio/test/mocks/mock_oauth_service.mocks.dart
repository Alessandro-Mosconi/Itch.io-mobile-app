// Mocks generated by Mockito 5.4.4 from annotations
// in itchio/test/mock_oauth_service.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i7;

import 'package:itchio/services/oauth_service.dart' as _i4;
import 'package:logger/logger.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;
import 'package:shared_preferences/shared_preferences.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLogger_0 extends _i1.SmartFake implements _i2.Logger {
  _FakeLogger_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSharedPreferences_1 extends _i1.SmartFake
    implements _i3.SharedPreferences {
  _FakeSharedPreferences_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [OAuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockOAuthService extends _i1.Mock implements _i4.OAuthService {
  MockOAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Logger get logger => (super.noSuchMethod(
        Invocation.getter(#logger),
        returnValue: _FakeLogger_0(
          this,
          Invocation.getter(#logger),
        ),
      ) as _i2.Logger);

  @override
  set logger(_i2.Logger? _logger) => super.noSuchMethod(
        Invocation.setter(
          #logger,
          _logger,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.SharedPreferences get prefs => (super.noSuchMethod(
        Invocation.getter(#prefs),
        returnValue: _FakeSharedPreferences_1(
          this,
          Invocation.getter(#prefs),
        ),
      ) as _i3.SharedPreferences);

  @override
  set prefs(_i3.SharedPreferences? _prefs) => super.noSuchMethod(
        Invocation.setter(
          #prefs,
          _prefs,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.GetInitialLink get getInitialLink => (super.noSuchMethod(
        Invocation.getter(#getInitialLink),
        returnValue: () => _i5.Future<String?>.value(),
      ) as _i4.GetInitialLink);

  @override
  _i4.LinkStream get linkStream => (super.noSuchMethod(
        Invocation.getter(#linkStream),
        returnValue: () => _i5.Stream<String?>.empty(),
      ) as _i4.LinkStream);

  @override
  _i5.Stream<bool> get onAuthenticationSuccess => (super.noSuchMethod(
        Invocation.getter(#onAuthenticationSuccess),
        returnValue: _i5.Stream<bool>.empty(),
      ) as _i5.Stream<bool>);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i5.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> initUniLinks() => (super.noSuchMethod(
        Invocation.method(
          #initUniLinks,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  void handleLink(String? link) => super.noSuchMethod(
        Invocation.method(
          #handleLink,
          [link],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<void> startOAuth() => (super.noSuchMethod(
        Invocation.method(
          #startOAuth,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  void handleAccessToken(String? accessToken) => super.noSuchMethod(
        Invocation.method(
          #handleAccessToken,
          [accessToken],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<void> saveAccessTokenToSharedPreferences(String? accessToken) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveAccessTokenToSharedPreferences,
          [accessToken],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String> getAccessToken() => (super.noSuchMethod(
        Invocation.method(
          #getAccessToken,
          [],
        ),
        returnValue: _i5.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #getAccessToken,
            [],
          ),
        )),
      ) as _i5.Future<String>);

  @override
  void logout() => super.noSuchMethod(
        Invocation.method(
          #logout,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
