import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/filter.dart';

class SavedSearchesProvider with ChangeNotifier {
  final Logger logger = Logger(printer: PrettyPrinter());

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
}
