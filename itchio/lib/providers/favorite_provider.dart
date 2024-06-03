import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helperClasses/Game.dart';
import 'package:http/http.dart' as http;

class FavoriteProvider with ChangeNotifier {
  List<Game> _favorites = [];
  final Logger logger = Logger(printer: PrettyPrinter());

  List<Game> get favorites => _favorites;

  Future<void> addFavorite(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    logger.i(token);

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    logger.i(token);

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games/${game.getKey()}');
    await dbRef.update(
        game.toMap()
    );

    if (!_favorites.contains(game)) {
      _favorites.add(game);
      notifyListeners();
    }
  }

  Future<void> removeFavorite(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games/${game.getKey()}');
    await dbRef.remove();

    if (_favorites.contains(game)) {
      _favorites.remove(game);
      notifyListeners();
    }
  }

  bool isFavorite(Game game) {
    return _favorites.map((g) => g.getKey()).contains(game.getKey());
  }

  Future<List<Game>> fetchFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    var key = "favorites";

    if (prefs.getString(key) != null && checkTimestamp(prefs.getInt("${key}_timestamp"))) {
      _favorites = await _getCachedFavorites(prefs, key);
    } else {
      _favorites = await _fetchFavoritesFromNetwork(key, prefs);
    }
    notifyListeners();

    return _favorites;
  }

  Future<List<Game>> _getCachedFavorites(SharedPreferences prefs, String key) async {
    String body = prefs.getString(key)!;
    List<dynamic>? results = json.decode(body);
    return results?.map((r) => Game(r)).toList() ?? [];
  }

  Future<List<Game>> _fetchFavoritesFromNetwork(String key, SharedPreferences prefs) async {

    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games');

    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic data = snapshot.value;
      List<Game> favorites = [];
      if (data is Map<Object?, Object?>) {
        data.forEach((key, value) {
          if (key is String && value is Map<String, dynamic>) {
            favorites.add(Game(value));
          } else if (key is String && value is Map<Object?, Object?>) {
            final Map<String, dynamic> convertedValue = value.map((k, v) => MapEntry(k.toString(), v));
            favorites.add(Game(convertedValue));
          } else {
            logger.e('Unexpected key/value types: key = ${key.runtimeType}, value = ${value.runtimeType}');
          }
        });
      } else {
        logger.e('Data is not a Map: ${data.runtimeType}');
      }

      return favorites;
      /*
      prefs.setString(key, json.encode(snapshot.value));
      prefs.setInt("${key}_timestamp", DateTime.now().millisecondsSinceEpoch);
      return snapshot.value .map((r) => Game(r)).toList() ?? [];*/
    } else {
      return [];
    }
  }


  bool checkTimestamp(int? timestamp){
    // 172800000 = 2 days in ms
    return (timestamp == null) || ((timestamp + 172800000) > DateTime.now().millisecondsSinceEpoch);
  }
}
