import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/oauth_service.dart';
import '../providers/theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OAuthService authService = Provider.of<OAuthService>(context, listen: false);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
        title: Text('Settings'),
    backgroundColor: theme.scaffoldBackgroundColor, // Use the scaffold background color
    elevation: 0, // Optional: remove shadow for a flat look
    ),
    body: Container(
    color: theme.scaffoldBackgroundColor, // Ensure the body has the same background color
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Theme Mode',
    ),
    ListTile(
    title: Text('Device Theme'),
    leading: Icon(Icons.devices),
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
      leading: Icon(Icons.wb_sunny),
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
        leading: Icon(Icons.nights_stay),
        trailing: Radio(
          value: ThemeMode.dark,
          groupValue: themeNotifier.themeMode,
          onChanged: (value) {
            themeNotifier.setThemeMode(value as ThemeMode);
          },
        ),
      ),
      Divider(),
      Text(
        'Theme Selection',
      ),
      ListTile(
        title: Text('Standard Theme'),
        leading: Icon(Icons.brightness_1, color: Colors.grey),
        trailing: Radio(
          value: 'standard',
          groupValue: themeNotifier.currentTheme,
          onChanged: (value) {
            themeNotifier.setTheme(value as String);
          },
        ),
      ),
      ListTile(
        title: Text('Fluxoki Theme'),
        leading: Icon(Icons.brightness_1, color: Colors.orange),
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
        leading: Icon(Icons.brightness_1, color: Colors.blueGrey),
        trailing: Radio(
          value: 'abyss',
          groupValue: themeNotifier.currentTheme,
          onChanged: (value) {
            themeNotifier.setTheme(value as String);
          },
        ),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
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

