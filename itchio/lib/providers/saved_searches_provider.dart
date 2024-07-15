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

  get savedSearchesKey => _savedSearchesKey;
  get savedSearchesTimestampKey => _savedSearchesTimestampKey;

  Future<void> deleteSavedSearch(String type, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');
    String key = _generateTopicHash(type, filters);
    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.remove();
    String body = prefs.getString("saved_searches")!;
    List<dynamic> results = json.decode(body);
    results.removeWhere((r) {
      return r['type'] == type && r['filters'] == filters;
    });
    prefs.setString("saved_searches", json.encode(results));
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
    String body = prefs.getString("saved_searches")!;
    List<dynamic> results = json.decode(body);
    results = results.map((r) {
      if (r['type'] == type && r['filters'] == filters) {
        r['notify'] = notify;
      }
      return r;
    }).toList();
    prefs.setString("saved_searches", json.encode(results));
  }

  String _generateTopicHash(String type, String filters) {
    String typeDefault = type;
    return sha256.convert(utf8.encode(typeDefault + filters)).toString(); // key
  }

  Future<List<SavedSearch>> fetchSavedSearch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      if (_isCacheValid(prefs)) {
        return _getFromCache(prefs);
      }

      final response = await http.post(
        Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/get_saved_search_carousel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        List<dynamic> results = json.decode(response.body);
        _saveToCache(prefs, response.body);
        return results.map((r) => SavedSearch(r)).toList();
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
    return savedSearches!= null && timestamp != null &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)) < cacheValidDuration;
  }

  List<SavedSearch> _getFromCache(SharedPreferences prefs) {
    String body = prefs.getString(savedSearchesKey)!;
    List<dynamic> results = json.decode(body);
    return results.map((r) => SavedSearch(r)).toList();
  }

  void _saveToCache(SharedPreferences prefs, String data) {
    prefs.setString(savedSearchesKey, data);
    prefs.setInt(savedSearchesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> refreshSavedSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(savedSearchesKey);
    prefs.remove(savedSearchesTimestampKey);
    notifyListeners();
  }
}
