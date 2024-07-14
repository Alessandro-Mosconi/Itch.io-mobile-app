import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:itchio/models/game.dart';

void main() {
  group('SavedSearch', () {
    test('should create SavedSearch from Map', () {
      final data = {
        'type': 'testType',
        'filters': 'testFilters',
        'notify': true,
        'items': [
          {'id': 1, 'title': 'Game 1'},
          {'id': 2, 'title': 'Game 2'},
        ],
      };

      final savedSearch = SavedSearch(data);

      expect(savedSearch.type, 'testType');
      expect(savedSearch.filters, 'testFilters');
      expect(savedSearch.notify, true);
      expect(savedSearch.items?.length, 2);
      expect(savedSearch.items?[0].title, 'Game 1');
      expect(savedSearch.items?[1].title, 'Game 2');
    });

    test('should create SavedSearch from JSON', () {
      final jsonString = '{"type":"testType","filters":"testFilters","notify":false,"items":[{"id":1,"title":"Game 1"}]}';

      final savedSearch = SavedSearch.fromJson(jsonString);

      expect(savedSearch.type, 'testType');
      expect(savedSearch.filters, 'testFilters');
      expect(savedSearch.notify, false);
      expect(savedSearch.items?.length, 1);
      expect(savedSearch.items?[0].title, 'Game 1');
    });

    test('should set notify value', () {
      final savedSearch = SavedSearch({'notify': false});

      savedSearch.setNotify(true);

      expect(savedSearch.notify, true);
    });

    test('should generate correct key', () {
      final savedSearch = SavedSearch({
        'type': 'testType',
        'filters': 'testFilters',
      });

      final key = savedSearch.getKey();

      expect(key, isA<String>());
      expect(key.length, 64); // SHA-256 hash is 64 characters long
    });

    test('should generate correct key from parameters', () {
      final key = SavedSearch.getKeyFromParameters('testType', 'testFilters');

      expect(key, isA<String>());
      expect(key.length, 64); // SHA-256 hash is 64 characters long
    });

    test('should handle null values', () {
      final savedSearch = SavedSearch({});

      expect(savedSearch.type, null);
      expect(savedSearch.filters, null);
      expect(savedSearch.notify, null);
      expect(savedSearch.items, isEmpty);

      final key = savedSearch.getKey();
      expect(key, isA<String>());
      expect(key.length, 64);
    });
  });
}