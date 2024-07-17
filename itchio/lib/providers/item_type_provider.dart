import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/item_type.dart';

class ItemTypeProvider with ChangeNotifier {
  final Logger logger = Logger(printer: PrettyPrinter());

  List<ItemType> _itemTypes = [];
  List<ItemType> get itemTypes => _itemTypes;

  Future<List<ItemType>> fetchTabs() async {
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/items/item_types');
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final List<dynamic> data = snapshot.value as List<dynamic>;
      List<ItemType> itemTypes = data.map((item) => ItemType(item)).toList();

      _itemTypes = itemTypes;
      return itemTypes;
    } else {
      logger.i('No item type found.');
      return [];
    }
  }
}
