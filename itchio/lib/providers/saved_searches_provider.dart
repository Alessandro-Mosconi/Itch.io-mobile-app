import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SavedSearchesProvider with ChangeNotifier {
  final Logger logger = Logger(printer: PrettyPrinter());

  final Duration cacheValidDuration = Duration(days: 2);
  final String _savedSearchesKey = "saved_searches";
  final String _savedSearchesTimestampKey = "saved_searches_timestamp";

  List<SavedSearch> _savedSearches = [];

  get savedSearchesKey => _savedSearchesKey;
  get savedSearchesTimestampKey => _savedSearchesTimestampKey;

  List<SavedSearch> get savedSearches => _savedSearches;

  Future<void> deleteSavedSearch(String type, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');
    String key = _generateTopicHash(type, filters);
    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.remove();
    _savedSearches.removeWhere((r) => r.type == type && r.filters == filters);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> changeNotifyField(String type, String filters, bool notify) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');
    String key = _generateTopicHash(type, filters);
    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.update({
      "filters": filters,
      "type": type,
      "notify": notify
    });
    final index = _savedSearches.indexWhere((r) => r.type == type && r.filters == filters);
    if (index != -1) {
      _savedSearches[index].setNotify(notify);
    }
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> reorderSavedSearches(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final SavedSearch item = _savedSearches.removeAt(oldIndex);
    _savedSearches.insert(newIndex, item);
    await _saveToPrefs();
    notifyListeners();
  }

  String _generateTopicHash(String type, String filters) {
    String typeDefault = type;
    return sha256.convert(utf8.encode(typeDefault + filters)).toString();
  }

  Future<List<SavedSearch>> fetchSavedSearch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      if (_isCacheValid(prefs)) {
        _savedSearches = _getFromCache(prefs);
        return _savedSearches;
      }

      final response = await http.post(
        Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/get_saved_search_carousel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        List<dynamic> results = json.decode(response.body);
        _savedSearches = results.map((r) => SavedSearch(r)).toList();
        _saveToCache(prefs, response.body);
        return _savedSearches;
      } else {
        throw Exception('Failed to load saved search results');
      }
    } catch (e) {
      logger.e('Error fetching saved searches: $e');
      rethrow;
    }
  }

  bool _isCacheValid(SharedPreferences prefs) {
    final timestamp = prefs.getInt(savedSearchesTimestampKey);
    String? savedSearches = prefs.getString(savedSearchesKey);
    return savedSearches != null && timestamp != null &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)) < cacheValidDuration;
  }

  List<SavedSearch> _getFromCache(SharedPreferences prefs) {
    String body = prefs.getString(savedSearchesKey)!;
    List<dynamic> results = json.decode(body);
    return results.map((r) => SavedSearch(r)).toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearchesJson = json.encode(_savedSearches.map((search) => search.toJson()).toList());
    await prefs.setString(savedSearchesKey, savedSearchesJson);
    await prefs.setInt(savedSearchesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  void _saveToCache(SharedPreferences prefs, String data) {
    prefs.setString(savedSearchesKey, data);
    prefs.setInt(savedSearchesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> refreshSavedSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(savedSearchesKey);
    prefs.remove(savedSearchesTimestampKey);
    await fetchSavedSearch();
    notifyListeners();
  }
}