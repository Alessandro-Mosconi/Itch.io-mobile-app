import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBookmarkProvider with ChangeNotifier {
  final Logger logger = Logger(printer: PrettyPrinter());

  List<String> _searchBookmarks = [];
  List<String> get searchBookmarks => _searchBookmarks;

  Future<void> addSearchBookmark(String tab, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/${SavedSearch.getKeyFromParameters(tab, filters)}');
    await dbRef.update(
      {
        'type': tab,
        'filters': filters,
        'notify': false
      }
    );

    String bookmark = '$tab$filters';
    List<String> order = prefs.getStringList("saved_searches_order") ?? [];
    if (!order.contains(SavedSearch.getKeyFromParameters(tab, filters))) {
      order.add(SavedSearch.getKeyFromParameters(tab, filters));
      prefs.setStringList("saved_searches_order", order);
    }

    if (!_searchBookmarks.contains(bookmark)) {
      _searchBookmarks.add(bookmark);
      notifyListeners();
    }
    prefs.remove("saved_searches");
  }

  Future<void> removeSearchBookmark(String tab, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/${SavedSearch.getKeyFromParameters(tab, filters)}');
    await dbRef.remove();

    String bookmark = '$tab$filters';
    _searchBookmarks.remove(bookmark);
    List<String> order = prefs.getStringList("saved_searches_order") ?? [];
    order.removeWhere((r) => r == SavedSearch.getKeyFromParameters(tab, filters));
    prefs.setStringList("saved_searches_order", order);
    notifyListeners();
    prefs.remove("saved_searches");
  }

  bool isSearchBookmarked(String tab, String filters) {
    String bookmark = '$tab$filters';
    logger.i(_searchBookmarks);
    return _searchBookmarks.contains(bookmark);
  }

  Future<void> reloadBookMarkProvider() async {

    await fetchBookmarks();
    notifyListeners();
  }

  Future<List<String>> fetchBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    _searchBookmarks = await _fetchBookmarksFromNetwork(prefs);
    notifyListeners();

    return _searchBookmarks;
  }

  Future<List<String>> _fetchBookmarksFromNetwork(SharedPreferences prefs) async {

    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}');

    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic data = snapshot.value;
      List<String> bookmarks = getBookmarksFromSnapshotValue(data);
      return bookmarks;
    } else {
      return [];
    }
  }

  List<String> getBookmarksFromSnapshotValue(data) {
    List<String> bookmarks = [];
    if (data is Map<Object?, Object?>) {
      data.forEach((key, value) {
        if (key is String && value is Map<String, String>) {
          bookmarks.add(value['type']! + value['filters']!);
        } else if (key is String && value is Map<Object?, Object?>) {
          final Map<String, String> convertedValue = value.map((k, v) => MapEntry(k.toString(), v.toString()));
          bookmarks.add(convertedValue['type']! + convertedValue['filters']!);
        } else {
          logger.e('Unexpected key/value types: key = ${key.runtimeType}, value = ${value.runtimeType}');
        }
      });
    } else {
      logger.e('Data is not a Map: ${data.runtimeType}');
    }

    return bookmarks;
  }
}
