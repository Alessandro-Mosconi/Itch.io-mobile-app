import 'package:flutter/material.dart';

class SearchBookmarkProvider with ChangeNotifier {
  List<String> _searchBookmarks = [];

  List<String> get searchBookmarks => _searchBookmarks;

  void addSearchBookmark(String tab, String filters) {
    String bookmark = '$tab$filters';
    if (!_searchBookmarks.contains(bookmark)) {
      _searchBookmarks.add(bookmark);
      notifyListeners();
    }
  }

  void removeSearchBookmark(String tab, String filters) {
    String bookmark = '$tab$filters';
    _searchBookmarks.remove(bookmark);
    notifyListeners();
  }

  bool isSearchBookmarked(String tab, String filters) {
    String bookmark = '$tab$filters';
    return _searchBookmarks.contains(bookmark);
  }
}
