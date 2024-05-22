import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'oauth_service.dart';
import 'theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OAuthService authService = Provider.of<OAuthService>(context, listen: false);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(themeNotifier.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
              title: Text('Dark Mode'),
              trailing: Switch(
                value: themeNotifier.isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme();
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                authService.logout();
                Navigator.pop(context); // Close the settings page
              },
            ),
          ],
        ),
      ),
    );
  }
}
