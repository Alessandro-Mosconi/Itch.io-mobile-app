import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'homePage.dart';
import 'firebase_options.dart';
import 'oauth_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await requestNotificationPermissions();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message);
  });

  await setupNotifications();

  FirebaseMessaging.instance.subscribeToTopic('new-games');
  runApp(ProviderApp());
}

Future<void> setupNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/itch');


  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false
  );


  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics);
}


Future<void> requestNotificationPermissions() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  print('User granted permission: ${settings.authorizationStatus == AuthorizationStatus.authorized}');
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
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
      home: const HomePage(title: 'Itch.io'),
    );
  }
}


