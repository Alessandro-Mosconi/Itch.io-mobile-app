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
  const MainView({super.key});

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

    Provider.of<PageProvider>(context, listen: false).navigateToIndexWithPage(1, SearchPage(initialTab: type, initialFilters: filters));
  }

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
