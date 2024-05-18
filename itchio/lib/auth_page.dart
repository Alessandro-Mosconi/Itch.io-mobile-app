import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'oauth_service.dart';
import 'custom_app_bar.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<OAuthService>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            authService.startOAuth();
          },
          child: Text('Authenticate'),
        ),
      ),
    );
  }
}
