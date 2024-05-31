import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/page_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../views/home_page.dart';
import '../views/search_page.dart';
import '../views/favorite_page.dart';
import '../views/bookmark_page.dart';
import '../views/profile_page.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    FavoritePage(),
    BookmarkPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PageProvider>(
      builder: (context, pageProvider, child) {
        return Scaffold(
          body: pageProvider.extraPage ?? _widgetOptions.elementAt(pageProvider.selectedIndex),
          bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: pageProvider.selectedIndex,
            onTap: (index) {
              pageProvider.setSelectedIndex(index);
            },
          ),
        );
      },
    );
  }
}
