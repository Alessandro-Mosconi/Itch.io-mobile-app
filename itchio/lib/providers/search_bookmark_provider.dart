import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:itchio/helperClasses/SavedSearch.dart';
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
    notifyListeners();
    prefs.remove("saved_searches");
  }

  bool isSearchBookmarked(String tab, String filters) {
    String bookmark = '$tab$filters';
    return _searchBookmarks.contains(bookmark);
  }
}
