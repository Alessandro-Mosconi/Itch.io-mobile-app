import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:itchio/models/user.dart';
import 'package:itchio/models/jam_game.dart';

void main() {
  group('User class tests', () {
    test('Test User constructor', () {
      Map<String, dynamic> userData = {
        'username': 'test_user',
        'url': 'http://example.com/user/1',
        'id': 1,
        'display_name': 'Test User',
        'cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
        'gamer': true,
        'developer': false,
        'img': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
        'number_of_projects': '5',
      };

      User user = User(userData);

      expect(user.username, 'test_user');
      expect(user.url, 'http://example.com/user/1');
      expect(user.id, 1);
      expect(user.displayName, 'Test User');
      expect(user.coverUrl,
          'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(user.isGamer, true);
      expect(user.isDeveloper, false);
      expect(user.avatar,
          'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(user.numberOfProjects, 5);
    });

    test('Test User toMap', () {
      User user = User({
        'username': 'test_user',
        'url': 'http://example.com/user/1',
        'id': 1,
        'display_name': 'Test User',
        'cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
        'gamer': true,
        'developer': false,
        'img': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
        'number_of_projects': '5',
      });

      Map<String, Object?> userMap = user.toMap();

      expect(userMap['username'], 'test_user');
      expect(userMap['url'], 'http://example.com/user/1');
      expect(userMap['id'], 1);
      expect(userMap['display_name'], 'Test User');
      expect(userMap['cover_url'],
          'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(userMap['gamer'], true);
      expect(userMap['developer'], false);
      expect(userMap['img'],
          'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(userMap['number_of_projects'], 5);
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
