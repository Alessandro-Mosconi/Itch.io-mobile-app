// Mocks generated by Mockito 5.4.4 from annotations
// in itchio/test/mock_item_type_provider.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i6;

import 'package:itchio/models/item_type.dart' as _i4;
import 'package:itchio/providers/item_type_provider.dart' as _i3;
import 'package:logger/logger.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

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

/// A class which mocks [ItemTypeProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockItemTypeProvider extends _i1.Mock implements _i3.ItemTypeProvider {
  MockItemTypeProvider() {
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
  List<_i4.ItemType> get itemTypes => (super.noSuchMethod(
        Invocation.getter(#itemTypes),
        returnValue: <_i4.ItemType>[],
      ) as List<_i4.ItemType>);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i5.Future<List<_i4.ItemType>> fetchTabs() => (super.noSuchMethod(
        Invocation.method(
          #fetchTabs,
          [],
        ),
        returnValue: _i5.Future<List<_i4.ItemType>>.value(<_i4.ItemType>[]),
      ) as _i5.Future<List<_i4.ItemType>>);

  @override
  void addListener(_i6.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i6.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
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
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
