import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../views/home_page.dart';
import '../views/search_page.dart';
import '../views/favorite_page.dart';
import '../views/profile_page.dart';
import 'jams_page.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const SearchPage(),
    const JamsPage(),
    const FavoritePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message);
    });
  }

  void _handleMessageTap(RemoteMessage message) {
    String type = message.data['type'];
    String filters = message.data['filters'];

    Provider.of<PageProvider>(context, listen: false).setSelectedIndex(1);
    Provider.of<PageProvider>(context, listen: false).pushExtraPage(
        SearchPage(initialTab: type, initialFilters: filters)
    );
  }

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
            body: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0 && pageProvider.canGoBack()) {
                  pageProvider.goBack();
                }
              },
              child: pageProvider.currentExtraPage ??
                  _widgetOptions[pageProvider.selectedIndex],
            ),
            bottomNavigationBar: pageProvider.isExtraPageVisible
                ? null
                : MyBottomNavigationBar(
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