import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itchio/models/game.dart';
import 'package:logger/logger.dart';

void main() {
  group('Game class tests', () {
    test('Test Game constructor', () {
      Map<String, dynamic> sampleData = {
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

      Game game = Game(sampleData);

      expect(game.views_count, 100);
      expect(game.url, 'http://example.com/game/1');
      expect(game.id, 1);
      expect(game.short_text, 'Short description');
      expect(game.min_price, 0);
      expect(game.price, 0.0);
      expect(game.type, 'action');
      expect(game.p_windows, false);
      expect(game.p_linux, false);
      expect(game.p_osx, false);
      expect(game.p_android, false);
      expect(game.title, 'Game1');
      expect(game.published_at, '2023-01-01T00:00:00Z');
      expect(game.can_be_bought, true);
      expect(game.classification, 'indie');
      expect(game.created_at, '2023-01-01T00:00:00Z');
      expect(game.in_press_system, false);
      expect(game.cover_url, 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(game.purchases_count, 50);
      expect(game.published, true);
      expect(game.downloads_count, 200);
      expect(game.user!.username, 'example_user');
      expect(game.still_cover_url, 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(game.imageurl, 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(game.author, 'Example Author');
      expect(game.currency, 'USD');
    });

    test('Test getCurrencySymbol', () {
      Game game = Game({
        'currency': 'USD',
      });

      expect(game.getCurrencySymbol(), '\$');
    });

    test('Test getFormatPriceWithCurrency', () {
      Game game = Game({
        'price': 10.5,
        'currency': 'USD',
      });

      expect(game.getFormatPriceWithCurrency(), '10.50\$');
    });

    test('Test toMap', () {
      Map<String, dynamic> sampleData = {
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

      Game game = Game(sampleData);
      Map<String, Object?> gameMap = game.toMap();

      expect(gameMap['views_count'], 100);
      expect(gameMap['url'], 'http://example.com/game/1');
      expect(gameMap['id'], 1);
      expect(gameMap['short_text'], 'Short description');
      expect(gameMap['min_price'], 0);
      expect(gameMap['price'], 0.0);
      expect(gameMap['type'], 'action');
      expect(gameMap['p_windows'], false);
      expect(gameMap['p_linux'], false);
      expect(gameMap['p_osx'], false);
      expect(gameMap['p_android'], false);
      expect(gameMap['title'], 'Game1');
      expect(gameMap['published_at'], '2023-01-01T00:00:00Z');
      expect(gameMap['can_be_bought'], true);
      expect(gameMap['classification'], 'indie');
      expect(gameMap['created_at'], '2023-01-01T00:00:00Z');
      expect(gameMap['in_press_system'], false);
      expect(gameMap['cover_url'], 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(gameMap['purchases_count'], 50);
      expect(gameMap['published'], true);
      expect(gameMap['downloads_count'], 200);
      expect(gameMap['still_cover_url'], 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(gameMap['description'], 'Description of the game <img src="http://example.com/image.png">');
      expect(gameMap['imageurl'], 'https://img.itch.zone/aW1nLzE0Mjk3MzY2LnBuZw==/315x250%23c/d%2FXok6.png');
      expect(gameMap['author'], 'Example Author');
      expect(gameMap['currency'], 'USD');
    });

    test('Test getCleanDescription', () {
      Game game = Game({
        'description': 'Description of the game <img src="http://example.com/image.png">',
      });

      expect(game.getCleanDescription(), 'Description of the game');
    });

    test('Test getKey', () {
      Game game = Game({
        'url': 'http://example.com/game/1',
      });

      String expectedKey = sha256.convert(utf8.encode('http://example.com/game/1')).toString();
      expect(game.getKey(), expectedKey);
    });
  });
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
