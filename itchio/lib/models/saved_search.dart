import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:itchio/models/game.dart';

class SavedSearch {
  String? type;
  String? filters;
  bool? notify;
  List<Game>? items;

  SavedSearch({this.type, this.filters, this.notify, this.items});

  SavedSearch.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    filters = json['filters'];
    notify = json['notify'];
    items = (json['items'] as List<dynamic>?)?.map((item) => Game(item)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'filters': filters,
      'notify': notify,
      'items': items?.map((item) => item.toMap()).toList(),
    };
  }

  void setNotify(bool newValue) {
    notify = newValue;
  }

  String getKey() {
    String filtersDefault = filters ?? '';
    String typeDefault = type ?? 'games';
    return sha256.convert(utf8.encode(typeDefault + filtersDefault)).toString();
  }

  static String getKeyFromParameters(String type, String filters) {
    String filtersDefault = filters;
    String typeDefault = type;
    return sha256.convert(utf8.encode(typeDefault + filtersDefault)).toString();
  }
}