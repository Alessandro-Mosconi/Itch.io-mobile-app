import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:itchio/models/jam.dart';

void main() {
  group('Jam class tests', () {
    test('Test Jam constructor and properties', () {
      Jam sampleJam = getJam("Jam1");

      expect(sampleJam.hue, 120);
      expect(sampleJam.startDate, DateTime.parse('2023-01-01T00:00:00Z'));
      expect(sampleJam.endDate, DateTime.parse('2023-01-10T00:00:00Z'));
      expect(sampleJam.votingEndDate, null);
      expect(sampleJam.featured, 1);
      expect(sampleJam.id, 1);
      expect(sampleJam.title, 'Jam1');
      expect(sampleJam.highlight, true);
      expect(sampleJam.joined, 3);
      expect(sampleJam.url, 'https://sokpop.itch.io/clickyland');
      expect(sampleJam.generatedOn, 1622548800.0);

      expect(sampleJam.jamGames.length, 1);
      expect(sampleJam.jamGames.first.ratingCount, 10);

      String expectedKey = sha256.convert(utf8.encode('https://sokpop.itch.io/clickyland')).toString();
      expect(sampleJam.getKey(), expectedKey);
    });

    test('Test Jam fromJson', () {
      Map<String, dynamic> gameData = getGame("Game1").toMap();
      Map<String, dynamic> jamGameData = getJamGame(gameData);

      Map<String, dynamic> jamData = {
        'hue': 120,
        'start_date': '2023-01-01T00:00:00Z',
        'end_date': '2023-01-10T00:00:00Z',
        'voting_end_date': null,
        'featured': 1,
        'id': 1,
        'title': 'Jam1',
        'highlight': true,
        'joined': 3,
        'url': 'https://sokpop.itch.io/clickyland',
        'detail': {
          'generated_on': 1622548800.0,
          'jam_games': [jamGameData],
        },
      };
      Jam jamFromJson = Jam.fromJson(json.encode(jamData));

      expect(jamFromJson.hue, 120);
      expect(jamFromJson.startDate, DateTime.parse('2023-01-01T00:00:00Z'));
      expect(jamFromJson.endDate, DateTime.parse('2023-01-10T00:00:00Z'));
      expect(jamFromJson.votingEndDate, null);
      expect(jamFromJson.featured, 1);
      expect(jamFromJson.id, 1);
      expect(jamFromJson.title, 'Jam1');
      expect(jamFromJson.highlight, true);
      expect(jamFromJson.joined, 3);
      expect(jamFromJson.url, 'https://sokpop.itch.io/clickyland');

      expect(jamFromJson.jamGames.length, 1);
      expect(jamFromJson.jamGames.first.ratingCount, 10);

      String expectedKey = sha256.convert(utf8.encode('https://sokpop.itch.io/clickyland')).toString();
      expect(jamFromJson.getKey(), expectedKey);
    });

    test('Test Jam toMap', () {
      Jam sampleJam = getJam("Jam1");
      Map<String, Object?> jamMap = sampleJam.toMap();

      expect(jamMap['hue'], 120);
      expect(jamMap['start_date'], '2023-01-01T00:00:00.000Z');
      expect(jamMap['end_date'], '2023-01-10T00:00:00.000Z');
      expect(jamMap['voting_end_date'], null);
      expect(jamMap['featured'], 1);
      expect(jamMap['id'], 1);
      expect(jamMap['title'], 'Jam1');
      expect(jamMap['highlight'], true);
      expect(jamMap['joined'], 3);
      expect(jamMap['url'], 'https://sokpop.itch.io/clickyland');
      expect(jamMap['generated_on'], 1622548800.0);

      List<dynamic> jamGames = jamMap['jam_games'] as List<dynamic>;
      expect(jamGames.length, 1);
      expect(jamGames.first['rating_count'], 10);
    });

  });
}

Jam getJam(String title) {
  Map<String, dynamic> gameData = getGame("Game1").toMap();
  Map<String, dynamic> jamGameData = getJamGame(gameData);

  Map<String, dynamic> jamData = {
    'hue': 120,
    'start_date': '2023-01-01T00:00:00Z',
    'end_date': '2023-01-10T00:00:00Z',
    'voting_end_date': null,
    'featured': 1,
    'id': 1,
    'title': title,
    'highlight': true,
    'joined': 3,
    'url': 'https://sokpop.itch.io/clickyland',
    'detail': {
      'generated_on': 1622548800.0,
      'jam_games': [jamGameData],
    },
  };

  return Jam(jamData);
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

Game getGame(String title) {
  Map<String, dynamic> gameData = {
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
    'title': title,
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
    'user': getUser(),
    'still_cover_url': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'description': 'Description of the game <img src="http://example.com/image.png">',
    'imageurl': 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png',
    'author': 'Example Author',
    'currency': 'USD',
  };
  return Game(gameData);
}

Map<String, dynamic> getUser() {
  Map<String, dynamic> userData = {
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
  return userData;
}
