import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/filter.dart';

class FilterProvider with ChangeNotifier {
  final Logger logger = Logger(printer: PrettyPrinter());

  List<Filter> _filters = [];
  List<Filter> get filters => _filters;

  Future<List<Filter>> fetchFilters() async {
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/items/filters');
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final List<dynamic> data = snapshot.value as List<dynamic>;
      List<Filter> filters = data.map((item) => Filter(item)).toList();

      _filters = filters;
      return filters;
    } else {
      logger.i('No filters found.');
      return [];
    }
  }
}
