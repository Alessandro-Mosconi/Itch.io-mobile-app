import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helperClasses/Game.dart';
import 'package:http/http.dart' as http;

import '../helperClasses/Jam.dart';

class FavoriteProvider with ChangeNotifier {
  List<Game> _favoriteGames = [];
  List<Jam> _favoriteJams = [];
  final Logger logger = Logger(printer: PrettyPrinter());

  List<Game> get favoriteGames => _favoriteGames;
  List<Jam> get favoriteJams => _favoriteJams;

  Future<void> addFavoriteGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games/${game.getKey()}');
    await dbRef.update(
        game.toMap()
    );

    if (!_favoriteGames.map((g) => g.getKey()).contains(game.getKey())) {
      _favoriteGames.add(game);
      notifyListeners();
      prefs.remove('favorite_games');
    }
  }

  Future<void> removeFavoriteGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games/${game.getKey()}');
    await dbRef.remove();

    if (_favoriteGames.map((g) => g.getKey()).contains(game.getKey())) {
      _favoriteGames.remove(game);
      notifyListeners();
      prefs.remove('favorite_games');
    }
  }

  Future<void> addFavoriteJam(Jam jam) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');


    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/jams/${jam.getKey()}');
    await dbRef.update(
        jam.toMap()
    );

    if (!_favoriteJams.map((j) => j.getKey()).contains(jam.getKey())) {
      _favoriteJams.add(jam);
      notifyListeners();
      prefs.remove('favorite_jams');
    }
  }

  Future<void> removeFavoriteJam(Jam jam) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/jams/${jam.getKey()}');
    await dbRef.remove();

    if (_favoriteJams.map((j) => j.getKey()).contains(jam.getKey())) {
      _favoriteJams.remove(jam);
      notifyListeners();
      prefs.remove('favorite_jams');
    }

  }

  bool isFavoriteGame(Game game) {
    return _favoriteGames.map((g) => g.getKey()).contains(game.getKey());
  }
  bool isFavoriteJam(Jam jam) {
    return _favoriteJams.map((j) => j.getKey()).contains(jam.getKey());
  }

  Future<List<Game>> fetchFavoriteGames() async {
    final prefs = await SharedPreferences.getInstance();
    var key = "favorite_games";

    if (prefs.getString(key) != null && checkTimestamp(prefs.getInt("${key}_timestamp"))) {
      _favoriteGames = await _getCachedFavoriteGames(prefs, key);
    } else {
      _favoriteGames = await _fetchFavoriteGamesFromNetwork(key, prefs);
    }
    notifyListeners();

    return _favoriteGames;
  }

  Future<List<Game>> _getCachedFavoriteGames(SharedPreferences prefs, String key) async {
    String snapshotValue = prefs.getString(key)!;
    List<Game> favorites = getGamesFromSnapshotValue(json.decode(snapshotValue));
    return favorites;
  }

  Future<List<Game>> _fetchFavoriteGamesFromNetwork(String key, SharedPreferences prefs) async {

    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games');

    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic data = snapshot.value;
      List<Game> favorites = getGamesFromSnapshotValue(data);

      if(favorites.isNotEmpty){
        prefs.setString(key, json.encode(snapshot.value));
        prefs.setInt("${key}_timestamp", DateTime.now().millisecondsSinceEpoch);
      }

      return favorites;
    } else {
      return [];
    }
  }

  Future<List<Jam>> fetchFavoriteJams() async {
    final prefs = await SharedPreferences.getInstance();
    var key = "favorite_jams";

    if (prefs.getString(key) != null && checkTimestamp(prefs.getInt("${key}_timestamp"))) {
      _favoriteJams = await _getCachedFavoriteJams(prefs, key);
    } else {
      _favoriteJams = await _fetchFavoriteJamsFromNetwork(key, prefs);
    }
    notifyListeners();

    return _favoriteJams;
  }

  Future<List<Jam>> _getCachedFavoriteJams(SharedPreferences prefs, String key) async {
    String snapshotValue = prefs.getString(key)!;
    List<Jam> favorites = getJamsFromSnapshotValue(json.decode(snapshotValue));
    return favorites;
  }

  Future<List<Jam>> _fetchFavoriteJamsFromNetwork(String key, SharedPreferences prefs) async {

    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/jams');

    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic data = snapshot.value;
      List<Jam> favorites = getJamsFromSnapshotValue(data);

      if(favorites.isNotEmpty){
        prefs.setString(key, json.encode(snapshot.value));
        prefs.setInt("${key}_timestamp", DateTime.now().millisecondsSinceEpoch);
      }

      return favorites;
    } else {
      return [];
    }
  }

  List<Game> getGamesFromSnapshotValue(data) {
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
  }

  List<Jam> getJamsFromSnapshotValue(data) {
    List<Jam> favorites = [];
    if (data is Map<Object?, Object?>) {
      data.forEach((key, value) {
        if (key is String && value is Map<String, dynamic>) {
          favorites.add(Jam(value));
        } else if (key is String && value is Map<Object?, Object?>) {
          final Map<String, dynamic> convertedValue = value.map((k, v) => MapEntry(k.toString(), v));
          favorites.add(Jam(convertedValue));
        } else {
          logger.e('Unexpected key/value types: key = ${key.runtimeType}, value = ${value.runtimeType}');
        }
      });
    } else {
      logger.e('Data is not a Map: ${data.runtimeType}');
    }

    return favorites;
  }

  bool checkTimestamp(int? timestamp){
    // 86400000 = 1 days in ms
    return (timestamp == null) || ((timestamp + 86400000) > DateTime.now().millisecondsSinceEpoch);
  }
}
