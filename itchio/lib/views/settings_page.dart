import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/oauth_service.dart';
import '../providers/theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OAuthService authService = Provider.of<OAuthService>(context, listen: false);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
        title: const Text('Settings'),
    backgroundColor: theme.scaffoldBackgroundColor, // Use the scaffold background color
    elevation: 0, // Optional: remove shadow for a flat look
    ),
    body: Container(
    color: theme.scaffoldBackgroundColor, // Ensure the body has the same background color
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Theme Mode',
    ),
    ListTile(
    title: const Text('Device Theme'),
    leading: const Icon(Icons.devices),
    trailing: Radio(
    value: ThemeMode.system,
    groupValue: themeNotifier.themeMode,
    onChanged: (value) {
    themeNotifier.setThemeMode(value as ThemeMode);
    },
      key: const Key('systemThemeRadio'),
    ),
    ),
    ListTile(
      title: const Text('Light Mode'),
      leading: const Icon(Icons.wb_sunny),
      trailing: Radio(
        value: ThemeMode.light,
        groupValue: themeNotifier.themeMode,
        onChanged: (value) {
          themeNotifier.setThemeMode(value as ThemeMode);
        },
        key: const Key('lightModeRadio'),
      ),
    ),
      ListTile(
        title: const Text('Dark Mode'),
        leading: const Icon(Icons.nights_stay),
        trailing: Radio(
          value: ThemeMode.dark,
          groupValue: themeNotifier.themeMode,
          onChanged: (value) {
            themeNotifier.setThemeMode(value as ThemeMode);
          },
          key: const Key('darkModeRadio'),
        ),
      ),
      const Divider(),
      const Text(
        'Theme Selection',
      ),
      ListTile(
        title: const Text('Standard Theme'),
        leading: const Icon(Icons.brightness_1, color: Colors.grey),
        trailing: Radio(
          value: 'standard',
          groupValue: themeNotifier.currentTheme,
          onChanged: (value) {
            themeNotifier.setTheme(value as String);
          },
        ),
      ),
      ListTile(
        title: const Text('Fluxoki Theme'),
        leading: const Icon(Icons.brightness_1, color: Colors.orange),
        trailing: Radio(
          value: 'fluxoki',
          groupValue: themeNotifier.currentTheme,
          onChanged: (value) {
            themeNotifier.setTheme(value as String);
          },
          key: const Key('fluxokiThemeRadio'), //to test
        ),
      ),
      ListTile(
        title: const Text('Abyss Theme'),
        leading: const Icon(Icons.brightness_1, color: Colors.blueGrey),
        trailing: Radio(
          value: 'abyss',
          groupValue: themeNotifier.currentTheme,
          onChanged: (value) {
            themeNotifier.setTheme(value as String);
          },
        ),
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout'),
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

