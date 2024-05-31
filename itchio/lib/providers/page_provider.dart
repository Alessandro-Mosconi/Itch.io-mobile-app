import 'package:flutter/material.dart';
//  class that will manage the current page index and the list of pages:

class PageProvider with ChangeNotifier {
  int _selectedIndex = 0;
  Widget? _extraPage;

  int get selectedIndex => _selectedIndex;
  Widget? get extraPage => _extraPage;

  void setSelectedIndex(int index) {
    _extraPage = null;
    _selectedIndex = index;
    notifyListeners();
  }

  void setExtraPage(Widget page) {
    _extraPage = page;
    notifyListeners();
  }
}
