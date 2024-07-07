import 'dart:convert';
import 'package:logger/logger.dart';

final Logger logger = Logger(printer: PrettyPrinter());

class Option {
  String? name;
  String? label;
  bool isSelected = false;

  Option(dynamic data) {
    name = data['name'];
    label = data['label'];
    isSelected = data['isSelected'] ?? false;
  }

  Option.fromJson(String jsonFilter) {
    var data = json.decode(jsonFilter);
    name = data['name'];
    label = data['label'];
    isSelected = data['isSelected'] ?? false;
  }

  toJson() {
    return {
      'name': name,
      'label': label,
      'isSelected': isSelected,
    };
  }

}




