import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:itchio/models/jam_game.dart';

void main() {
  group('JamGame class tests', () {
    test('Test JamGame constructor', () {
      Map<String, dynamic> sampleData = {
        'rating_count': 10,
        'coolness': 5,
        'id': 1,
        'game': getGameMap(),
        'url': 'http://example.com/jam_game/1',
        'created_at': '2023-01-01T00:00:00Z',
        'field_responses': ['Good', 'Fun', 'Challenging'],
      };

      JamGame jamGame = JamGame(sampleData);

      expect(jamGame.ratingCount, 10);
      expect(jamGame.coolness, 5);
      expect(jamGame.id, 1);
      expect(jamGame.game!.title, 'Game1');
      expect(jamGame.url, 'http://example.com/jam_game/1');
      expect(jamGame.createdAt, DateTime.parse('2023-01-01T00:00:00Z'));
      expect(jamGame.fieldResponses, ['Good', 'Fun', 'Challenging']);
    });

    test('Test JamGame fromJson', () {
      String jsonJamGame = '''
        {
          "rating_count": 10,
          "coolness": 5,
          "id": 1,
          "game": ${json.encode(getGameMap())},
          "url": "http://example.com/jam_game/1",
          "created_at": "2023-01-01T00:00:00Z",
          "field_responses": ["Good", "Fun", "Challenging"]
        }
      ''';

      JamGame jamGame = JamGame.fromJson(jsonJamGame);

      expect(jamGame.ratingCount, 10);
      expect(jamGame.coolness, 5);
      expect(jamGame.id, 1);
      expect(jamGame.game!.title, 'Game1');
      expect(jamGame.url, 'http://example.com/jam_game/1');
      expect(jamGame.createdAt, DateTime.parse('2023-01-01T00:00:00Z'));
      expect(jamGame.fieldResponses, ['Good', 'Fun', 'Challenging']);
    });

    test('Test JamGame toMap', () {
      Map<String, dynamic> sampleData = {
        'rating_count': 10,
        'coolness': 5,
        'id': 1,
        'game': getGameMap(),
        'url': 'http://example.com/jam_game/1',
        'created_at': DateTime.parse('2023-01-01T00:00:00Z'),
        'field_responses': ['Good', 'Fun', 'Challenging'],
      };

      JamGame jamGame = JamGame(getJamGame(getGameMap()));
      Map<String, Object?> jamGameMap = jamGame.toMap();

      expect(jamGameMap['rating_count'], 10);
      expect(jamGameMap['coolness'], 5);
      expect(jamGameMap['id'], 1);
      expect(jamGameMap['url'], 'http://example.com/jam_game/1');
      expect(jamGameMap['created_at'], '2023-01-01T00:00:00.000Z');
      expect(jamGameMap['field_responses'], ['Good', 'Fun', 'Challenging']);
    });
  });
}

Map<String, dynamic> getJamGame(Map<String, dynamic> gameData) {
  Map<String, dynamic> jamGameData = {
    'rating_count': 10,
    'coolness': 5,
    'id': 1,
    'game': gameData,
    'url': 'http://example.com/jam_game/1',
    'created_at': '2023-01-01T00:00:00Z',
    'field_responses': ['Good', 'Fun', 'Challenging'],
  };
  return jamGameData;
}

Map<String, dynamic> getGameMap() {
  return {
    'views_count': 100,
    'url': 'http://example.com/game/1',
    'id': 1,
    'short_text': 'Short description',
    'min_price': 0,
    'price': 0.0,
    'type': 'action',
    'p_windows': false,
    'p_linux': false,
    'p_osx': false,
    'p_android': false,
    'title': 'Game1',
    'published_at': '2023-01-01T00:00:00Z',
    'can_be_bought': true,
    'classification': 'indie',
    'created_at': '2023-01-01T00:00:00Z',
    'in_press_system': false,
    'cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'purchases_count': 50,
    'published': true,
    'downloads_count': 200,
    'has_demo': 'No',
    'user': getUserMap(),
    'still_cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'description': 'Description of the game <img src="http://example.com/image.png">',
    'imageurl': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'author': 'Example Author',
    'currency': 'USD',
  };
}


Map<String, dynamic> getUserMap() {
  return {
    'username': 'example_user',
    'url': 'http://example.com/user/1',
    'id': 1,
    'display_name': 'Example User',
    'cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'gamer': true,
    'developer': false,
    'img': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'number_of_projects': '5',
  };
}
