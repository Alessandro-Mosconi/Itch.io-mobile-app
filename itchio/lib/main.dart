import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itchio/bookmark_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'oauth_service.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'auth_page.dart';
import 'settings_page.dart';
import 'theme_notifier.dart';
import 'custom_app_bar.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupNotifications();
  await subscribeToTopic();

  runApp(ProviderApp());
}

Future<void> setupNotifications() async {
  await requestNotificationPermissions();
  await initializeLocalNotifications();
  setupFirebaseMessagingListeners();
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

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/itch');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void setupFirebaseMessagingListeners() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message);
  });
}

void showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
  );
}

Future<void> subscribeToTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic('new-games');
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OAuthService>(
          create: (_) => _oauthService,
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
      ],
      child: MyApp(),
    );
  }

  @override
  void dispose() {
    _oauthService.dispose();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Itch.io',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: Colors.black, // Customize the primary color
          onPrimary: Colors.white,
          secondary: Colors.grey, // Customize the secondary color
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.white, // Customize the primary color
          onPrimary: Colors.black,
          secondary: Colors.grey, // Customize the secondary color
        ),
      ),
      themeMode: themeNotifier.currentTheme,
      home: AuthOrHomePage(),
    );
  }
}

class AuthOrHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<OAuthService>(context);

    if (authService.accessToken == null) {
      return AuthPage();
    } else {
      return MyHomePage();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    FavoritePage(),
    BookmarkPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
