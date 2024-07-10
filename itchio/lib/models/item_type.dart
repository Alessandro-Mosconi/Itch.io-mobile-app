import 'dart:convert';
import 'package:logger/logger.dart';

class ItemType {
  String? name;
  String? label;

  ItemType(dynamic data) {
    name = data['name'];
    label = data['label'];
  }

  ItemType.fromJson(String jsonFilter) {
    var data = json.decode(jsonFilter);
    name = data['name'];
    label = data['label'];
  }

  toJson() {
    return {
      'name': name,
      'label': label,
    };
  }

}




