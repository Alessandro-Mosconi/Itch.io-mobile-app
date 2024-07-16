import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:itchio/models/game.dart';

class SavedSearch {
  String? type;
  String? filters;
  bool? notify;
  List<Game>? items;

  SavedSearch(Map<String, dynamic> data) {
    type = data['type'];
    filters = data['filters'];
    notify = data['notify'];
    items = (data['items'] as List<dynamic>?)
        ?.map((d) => Game(d as Map<String, dynamic>))
        .toList() ?? [];
  }

  void setNotify(bool newValue) {
    notify = newValue;
  }

  String getKey() {
    String filtersDefault = filters ?? '';
    String typeDefault = type ?? 'games';
    String key = sha256.convert(utf8.encode(typeDefault + filtersDefault)).toString();
    return key;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'filters': filters,
      'notify': notify,
      'items': items?.map((game) => game.toMap()).toList(),
    };
  }

  static String getKeyFromParameters(String type, String filters) {
    String filtersDefault = filters;
    String typeDefault = type;
    String key = sha256.convert(utf8.encode(typeDefault + filtersDefault)).toString();
    return key;
  }
}