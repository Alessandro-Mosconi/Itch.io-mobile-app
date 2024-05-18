import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'oauth_service.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OAuthService authService = Provider.of<OAuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            authService.logout();
            Navigator.pop(context);  // Close the settings page
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
