import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/oauth_service.dart';
import '../views/auth_page.dart';
import '../views/main_view.dart';

class AuthOrHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<OAuthService>(context);

    if (authService.accessToken == null) {
      return AuthPage();
    } else {
      return MainView();
    }
  }
}
