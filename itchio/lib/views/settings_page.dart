import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/oauth_service.dart';
import '../providers/theme_notifier.dart';

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
          title: Text('Device Theme'),
          trailing: Radio(
            value: ThemeMode.system,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              themeNotifier.setThemeMode(value as ThemeMode);
            },
          ),
        ),
        ListTile(
          title: Text('Light Mode'),
          trailing: Radio(
            value: ThemeMode.light,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              themeNotifier.setThemeMode(value as ThemeMode);
            },
          ),
        ),
        ListTile(
          title: Text('Dark Mode'),
          trailing: Radio(
            value: ThemeMode.dark,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              themeNotifier.setThemeMode(value as ThemeMode);
            },
          ),
        ),
        Divider(),
        ListTile(
          title: Text('Fluxoki Theme'),
          trailing: Radio(
            value: 'fluxoki',
            groupValue: themeNotifier.currentTheme,
            onChanged: (value) {
              themeNotifier.setTheme(value as String);
            },
          ),
        ),
        ListTile(
          title: Text('Abyss Theme'),
          trailing: Radio(
            value: 'abyss',
            groupValue: themeNotifier.currentTheme,
            onChanged: (value) {
              themeNotifier.setTheme(value as String);
            },
          ),
        ),
        ListTile(
          title: Text('Hard Contrast Theme'),
          trailing: Radio(
            value: 'hardContrast',
            groupValue: themeNotifier.currentTheme,
            onChanged: (value) {
              themeNotifier.setTheme(value as String);
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

