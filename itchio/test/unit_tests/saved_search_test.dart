import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/saved_search.dart';

void main() {
  group('SavedSearch class tests', () {
    test('Test SavedSearch.fromJson', () {
      Map<String, dynamic> jsonData = {
        'type': 'action',
        'filters': 'platform=windows',
        'notify': true,
        'items': [
          {
            'id': 1,
            'title': 'Game 1',
            'type': 'action',
            'platforms': ['windows'],
            'price': 10.0,
          },
          {
            'id': 2,
            'title': 'Game 2',
            'type': 'adventure',
            'platforms': ['linux'],
            'price': 15.0,
          },
        ],
      };

      SavedSearch savedSearch = SavedSearch.fromJson(jsonData);

      expect(savedSearch.type, 'action');
      expect(savedSearch.filters, 'platform=windows');
      expect(savedSearch.notify, true);
      expect(savedSearch.items, isNotNull);
      expect(savedSearch.items!.length, 2);

      expect(savedSearch.items![0].id, 1);
      expect(savedSearch.items![0].title, 'Game 1');
      expect(savedSearch.items![0].type, 'action');
      expect(savedSearch.items![0].price, 10.0);
      expect(savedSearch.items![0].p_windows, true);
      expect(savedSearch.items![0].p_linux, false);
      expect(savedSearch.items![0].p_osx, false);
      expect(savedSearch.items![0].p_android, false);

      expect(savedSearch.items![1].id, 2);
      expect(savedSearch.items![1].title, 'Game 2');
      expect(savedSearch.items![1].type, 'adventure');
      expect(savedSearch.items![1].price, 15.0);
      expect(savedSearch.items![1].p_windows, false);
      expect(savedSearch.items![1].p_linux, true);
      expect(savedSearch.items![1].p_osx, false);
      expect(savedSearch.items![1].p_android, false);
    });

    test('Test SavedSearch.toJson', () {
      SavedSearch savedSearch = SavedSearch(
        type: 'action',
        filters: 'platform=windows',
        notify: true,
        items: [
          Game({
            'id': 1,
            'title': 'Game 1',
            'type': 'action',
            'platforms': ['windows'],
            'price': 10.0,
          }),
          Game({
            'id': 2,
            'title': 'Game 2',
            'type': 'adventure',
            'platforms': ['linux'],
            'price': 15.0,
          }),
        ],
      );

      Map<String, dynamic> jsonMap = savedSearch.toJson();

      expect(jsonMap['type'], 'action');
      expect(jsonMap['filters'], 'platform=windows');
      expect(jsonMap['notify'], true);
      expect(jsonMap['items'], isNotNull);
      expect(jsonMap['items'].length, 2);

      expect(jsonMap['items'][0]['id'], 1);
      expect(jsonMap['items'][0]['title'], 'Game 1');
      expect(jsonMap['items'][0]['type'], 'action');
      expect(jsonMap['items'][0]['price'], 10.0);

      expect(jsonMap['items'][1]['id'], 2);
      expect(jsonMap['items'][1]['title'], 'Game 2');
      expect(jsonMap['items'][1]['type'], 'adventure');
      expect(jsonMap['items'][1]['price'], 15.0);
    });

    test('Test SavedSearch.setNotify', () {
      SavedSearch savedSearch = SavedSearch(
        type: 'action',
        filters: 'platform=windows',
        notify: true,
        items: [],
      );

      expect(savedSearch.notify, true);

      savedSearch.setNotify(false);

      expect(savedSearch.notify, false);
    });

    test('Test SavedSearch.getKey', () {
      SavedSearch savedSearch = SavedSearch(
        type: 'action',
        filters: 'platform=windows',
        notify: true,
        items: [],
      );

      String key = savedSearch.getKey();

      String expectedKey = sha256.convert(utf8.encode('actionplatform=windows')).toString();

      expect(key, expectedKey);
    });

    test('Test SavedSearch.getKeyFromParameters', () {
      String key = SavedSearch.getKeyFromParameters('action', 'platform=windows');

      String expectedKey = sha256.convert(utf8.encode('actionplatform=windows')).toString();

      expect(key, expectedKey);
    });
  });
}
