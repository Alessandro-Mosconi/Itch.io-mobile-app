import 'dart:convert';

import 'option.dart';

class Filter {
  String? name;
  String? label;
  bool? isAlternative;
  List<Option> options = [];

  Filter(dynamic data) {
    name = data['name'];
    label = data['label'];
    isAlternative = data['isAlternative'];
    options = (data['options'] as List<dynamic>).map((o) => Option(o)).toList();
  }

  Filter.fromJson(String jsonFilter) {
    var data = json.decode(jsonFilter);
    name = data['name'];
    label = data['label'];
    isAlternative = data['isAlternative'];
    options = (data['options'] as List<dynamic>).map((o) => Option(o)).toList();

  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'isAlternative': isAlternative,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }

}




