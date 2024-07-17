import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../views/home_page.dart';
import '../views/search_page.dart';
import '../views/favorite_page.dart';
import '../views/profile_page.dart';
import 'jams_page.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  final List<Widget> _widgetOptions = const <Widget>[
    HomePage(),
    SearchPage(),
    JamsPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PageProvider>(
      builder: (context, pageProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            if (pageProvider.canGoBack()) {
              pageProvider.goBack();
              return false;
            }
            return true;
          },
          child: Scaffold(
            body: pageProvider.currentExtraPage ?? _widgetOptions[pageProvider.selectedIndex],
            bottomNavigationBar: MyBottomNavigationBar(
              currentIndex: pageProvider.selectedIndex,
              onTap: (index) {
                pageProvider.setSelectedIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}