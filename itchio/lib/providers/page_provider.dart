import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  int _selectedIndex = 0;
  List<int> _indexHistory = [0];
  List<Widget?> _extraPageHistory = [];

  int get selectedIndex => _selectedIndex;
  Widget? get currentExtraPage => _extraPageHistory.isNotEmpty ? _extraPageHistory.last : null;
  bool get isExtraPageVisible => _extraPageHistory.isNotEmpty;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      _indexHistory.add(index);
      _extraPageHistory.clear();
      notifyListeners();
    }
  }

  void pushExtraPage(Widget page) {
    _extraPageHistory.add(page);
    notifyListeners();
  }

  void setExtraPage(Widget page) {
    pushExtraPage(page);
  }

  void goBack() {
    if (_extraPageHistory.isNotEmpty) {
      _extraPageHistory.removeLast();
    } else if (_indexHistory.length > 1) {
      _indexHistory.removeLast();
      _selectedIndex = _indexHistory.last;
    }
    notifyListeners();
  }

  bool canGoBack() {
    return _extraPageHistory.isNotEmpty || _indexHistory.length > 1;
  }

  void clearExtraPage() {
    if (_extraPageHistory.isNotEmpty) {
      _extraPageHistory.removeLast();
      notifyListeners();
    }
  }

  void navigateToIndexWithPage(int index, Widget page) {
    setSelectedIndex(index);
    pushExtraPage(page);
  }
}