import 'package:flutter/material.dart';
import 'package:itchio/providers/filter_provider.dart';
import 'package:itchio/providers/item_type_provider.dart';
import 'package:itchio/providers/jams_provider.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/search_provider.dart';
import 'package:itchio/providers/user_provider.dart';
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

  final themeNotifier = ThemeNotifier();
  await themeNotifier.init();

  runApp(ProviderApp(themeNotifier: themeNotifier));
}

class ProviderApp extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const ProviderApp({Key? key, required this.themeNotifier}) : super(key: key);

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
        ChangeNotifierProvider<ThemeNotifier>.value(
          value: widget.themeNotifier,
        ),
        ChangeNotifierProvider<PageProvider>(
          create: (_) => PageProvider(),
        ),
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(),
        ),
        ChangeNotifierProvider<FilterProvider>(
          create: (_) => FilterProvider(),
        ),
        ChangeNotifierProvider<ItemTypeProvider>(
          create: (_) => ItemTypeProvider(),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(),
        ),
        ChangeNotifierProvider<SearchBookmarkProvider>(
          create: (_) => SearchBookmarkProvider(),
        ),
        ChangeNotifierProvider<SavedSearchesProvider>(
          create: (_) => SavedSearchesProvider(),
        ),
        ChangeNotifierProvider<JamsProvider>(
          create: (_) => JamsProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
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
  const MyApp({Key? key}) : super(key: key);

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