import 'dart:convert';

import 'package:itchio/helperClasses/Game.dart';

class SavedSearch {
  String? type;
  String? filters;
  List<Game>? items;

  SavedSearch(Map<String, dynamic> data) {
    type = data['type'];
    filters = data['filters'];
    items = (data['items'] as List<dynamic>?)
        ?.map((d) => Game(d as Map<String, dynamic>))
        .toList() ?? [];
  }

  SavedSearch.fromJson(String jsonUser) {
    var data = json.decode(jsonUser);
    type = data['type'];
    filters = data['filters'];
    items = (data['items'] as List<dynamic>?)
        ?.map((d) => Game(d as Map<String, dynamic>))
        .toList() ?? [];
  }
}



