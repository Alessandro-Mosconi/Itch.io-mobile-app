import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../services/oauth_service.dart';
import '../views/auth_page.dart';
import '../views/main_view.dart';

class AuthOrHomePage extends StatelessWidget {
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  AuthOrHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<OAuthService>(context, listen: false);

    return FutureBuilder(
      future: authService.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('An error occured while initializing: ${snapshot.error}')),
          );
        } else {
          if (authService.accessToken == null) {
            return const AuthPage();
          } else {
            return const MainView();
          }
        }
      },
    );
  }
}
