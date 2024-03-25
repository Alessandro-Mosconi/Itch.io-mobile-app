import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homePage.dart';
import 'oauth_service.dart'; // Import your OAuth service file

void main() {
  runApp(ProviderApp());
}

class ProviderApp extends StatefulWidget {
  @override
  _ProviderAppState createState() => _ProviderAppState();
}

class _ProviderAppState extends State<ProviderApp> {
  final OAuthService _oauthService = OAuthService();

  @override
  void initState() {
    super.initState();
    _oauthService.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OAuthService>(
      create: (_) => _oauthService,
      child: const MyApp(),
    );
  }

  @override
  void dispose() {
    _oauthService.dispose();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itch.io refactor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Itch.io refactor'),
    );
  }
}


