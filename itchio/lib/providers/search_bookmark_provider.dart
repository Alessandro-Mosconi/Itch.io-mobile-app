import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class SearchBookmarkProvider with ChangeNotifier {
  final Logger logger = Logger(printer: PrettyPrinter());

  Future<void> addSearchBookmark(String tab, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    String key = sha256.convert(utf8.encode(tab + filters)).toString();

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.update({"filters": filters, "type": tab});

    prefs.remove("saved_searches");
    notifyListeners();
  }

  Future<void> removeSearchBookmark(String tab, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    String key = sha256.convert(utf8.encode(tab + filters)).toString();

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.remove();

    notifyListeners();
  }
}
