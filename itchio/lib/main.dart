import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/oauth_service.dart';
import 'providers/page_provider.dart';
import 'providers/theme_notifier.dart';
import 'providers/favorite_provider.dart';
import 'providers/search_bookmark_provider.dart';
import 'views/auth_or_main_view.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderApp());
}

class ProviderApp extends StatefulWidget {
  const ProviderApp({super.key});

  @override
  _ProviderAppState createState() => _ProviderAppState();
}

class _ProviderAppState extends State<ProviderApp> {
  final OAuthService _oauthService = OAuthService();
  final NotificationService _notificationService = NotificationService(flutterLocalNotificationsPlugin);

  @override
  void initState() {
    super.initState();
    _oauthService.init();
    _notificationService.setupNotifications();
  }

  @override
  void dispose() {
    _oauthService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OAuthService>(
          create: (_) => _oauthService,
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider<PageProvider>(
          create: (_) => PageProvider(),
        ),
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(),
        ),
        ChangeNotifierProvider<SearchBookmarkProvider>(
          create: (_) => SearchBookmarkProvider(),
        ),
        Provider<NotificationService>(
          create: (_) => _notificationService,
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Itch.io',
      theme: themeNotifier.getLightThemeData(themeNotifier.currentTheme),
      darkTheme: themeNotifier.getDarkThemeData(themeNotifier.currentTheme),
      themeMode: themeNotifier.themeMode,
      home: AuthOrHomePage(),
    );
  }
}
