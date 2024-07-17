import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/oauth_service.dart';
import '../providers/theme_notifier.dart';
import '../providers/page_provider.dart';
import '../views/auth_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OAuthService authService = Provider.of<OAuthService>(context, listen: false);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final pageProvider = Provider.of<PageProvider>(context, listen: false);
    final theme = Theme.of(context);

    void logout() {
      authService.logout();
      pageProvider.resetToInitialState();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
            (Route<dynamic> route) => false,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
    body: SingleChildScrollView(
    child: Container(
    color: theme.scaffoldBackgroundColor,
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
              key: const Key('standardThemeRadio'),
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
              key: const Key('fluxokiThemeRadio'),
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
              key: const Key('abyssThemeRadio'),
            ),
          ),
          ListTile(
            title: const Text('Vibrant Theme'),
            leading: const Icon(Icons.brightness_auto, color: Colors.deepPurple),
            trailing: Radio(
              value: 'vibrant',
              groupValue: themeNotifier.currentTheme,
              onChanged: (value) {
                themeNotifier.setTheme(value as String);
              },
              key: const Key('vibrantThemeRadio'),
            ),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout'),
          onTap: logout,
        ),

        ],
        ),
        ),
    ),
        );
      }
    }

