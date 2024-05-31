import 'package:flutter/material.dart';
//  class that will manage the current page index and the list of pages:
class PageProvider with ChangeNotifier {
  int _selectedIndex = 0;
  Widget? _extraPage;
  bool _isExtraPageVisible = false;

  int get selectedIndex => _selectedIndex;
  Widget? get extraPage => _extraPage;
  bool get isExtraPageVisible => _isExtraPageVisible;

  void setSelectedIndex(int index) {
    _extraPage = null;
    _isExtraPageVisible = false;
    _selectedIndex = index;
    notifyListeners();
  }

  void setExtraPage(Widget page) {
    _extraPage = page;
    _isExtraPageVisible = true;
    notifyListeners();
  }

  void clearExtraPage() {
    _extraPage = null;
    _isExtraPageVisible = false;
    notifyListeners();
  }
}
