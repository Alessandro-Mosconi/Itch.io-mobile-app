import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/filter.dart';
import '../models/item_type.dart';
import '../models/option.dart';

class SearchProvider with ChangeNotifier {
  final Logger logger = Logger(printer: PrettyPrinter());

  Future<void> reloadSearchProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final keysToRemove = keys.where((key) => key.startsWith("cached_tab_result"));
    for (var key in keysToRemove) {
      await prefs.remove(key);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchTabResults(ItemType currentTab, List<Filter> filters) async {
    final concatenatedFilters = getSelectedOptions(filters).isNotEmpty
        ? '/${getSelectedOptions(filters).map((option) => option.name).join('/')}'
        : '';

    final prefs = await SharedPreferences.getInstance();

    final currentTabName = currentTab.name ?? 'games';

    if(prefs.getString("cached_tab_result/$currentTabName$concatenatedFilters") != null){
      final result = json.decode(prefs.getString("cached_tab_result/$currentTabName$concatenatedFilters")!);
      if(result['items'] is List) {
        return result;
      } else {
        result['items'] = [result['items']];
        return result;
      }
    }

    final response = await http.post(
      Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/item_list'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'filters': concatenatedFilters, 'type': currentTabName}),
    );

    if (response.statusCode == 200) {
      prefs.setString("cached_tab_result/$currentTabName$concatenatedFilters", response.body);
      return json.decode(response.body);
    } else {
      logger.e('Type: $currentTabName, Filters: $concatenatedFilters');
      logger.e('Failed to load tab results, status code: ${response.statusCode}');
      return <String, dynamic>{} as Map<String, dynamic>;
    }
  }


  Future<Map<String, dynamic>> fetchSearchResults(String query) async {
    final response = await http.get(
      Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/search?search=$query'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      logger.e('Failed to load search results, status code: ${response.statusCode}');
      throw Exception('Failed to load search results');
    }
  }

  List<Option> getSelectedOptions(List<Filter> filters) {
    return filters
        .expand((filter) => filter.options)
        .where((option) => option.isSelected)
        .toList();
  }
  }
