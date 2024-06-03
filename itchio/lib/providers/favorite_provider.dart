import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helperClasses/Game.dart';

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

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games/${game.title}');
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

    final DatabaseReference dbRef = dbInstance.ref('/favorites/${token!}/games/${game.title}');
    await dbRef.remove();

    if (_favorites.contains(game)) {
      _favorites.remove(game);
      notifyListeners();
    }
  }

  bool isFavorite(Game game) {
    return _favorites.contains(game);
  }
/*
  Future<List<Jam>> fetchJams(bool? includeDetails) async {
    includeDetails ??= false;
    final prefs = await SharedPreferences.getInstance();
    var key = includeDetails ? "saved_jams_details" : "saved_jams";

    if (prefs.getString(key) != null && checkTimestamp(prefs.getInt("${key}_timestamp"))) {
      return _getCachedJams(prefs, key);
    }

    return _fetchJamsFromNetwork(key, includeDetails, prefs);
  }

  Future<List<Jam>> _getCachedJams(SharedPreferences prefs, String key) async {
    String body = prefs.getString(key)!;
    List<dynamic>? results = json.decode(body);
    return results?.map((r) => Jam(r)).toList() ?? [];
  }*/
}
