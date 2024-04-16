import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homePage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'oauth_service.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.subscribeToTopic('allUsers');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle the message when the app is in the foreground
    print("Message received in foreground: ${message.messageId}");
  });

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


