import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_page.dart';
import 'oauth_service.dart';  // Ensure you have this if you're using OAuthService

class bottomBar extends StatefulWidget {
  final String title;

  const bottomBar({Key? key, required this.title}) : super(key: key);

  @override
  _bottomBarState createState() => _bottomBarState();
}

class _bottomBarState extends State<bottomBar> {
  int _selectedIndex = 0;

  // Only ProfilePage and an authentication action
  List<Widget> _pageOptions = [];

  @override
  void initState() {
    super.initState();
    _pageOptions = [
      Container(),  // Placeholder for auth action
      ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // If the second tab is selected, perform the auth action
    if (index == 0) {
      final OAuthService oAuthService = Provider.of<OAuthService>(context, listen: false);
      oAuthService.startOAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _pageOptions[_selectedIndex],  // Body changes based on the selected tab
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key),
            label: 'Auth',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
