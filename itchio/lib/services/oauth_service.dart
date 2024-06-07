import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // needed for ChangeNotifier
import 'package:url_launcher/url_launcher.dart';

typedef GetInitialLink = Future<String?> Function();
typedef LinkStream = Stream<String?> Function();

class OAuthService extends ChangeNotifier {
  late Logger logger;
  late SharedPreferences prefs;
  final GetInitialLink getInitialLink;
  final LinkStream linkStream;

  StreamSubscription? _sub;
  String? _accessToken; // Added to store the access token

  OAuthService({
    SharedPreferences? sharedPreferences,
    Logger? customLogger,
    GetInitialLink? getInitialLink,
    LinkStream? linkStream,
  })  : getInitialLink = getInitialLink ?? getInitialLinkImpl,
        linkStream = linkStream ?? linkStreamImpl {
    if (sharedPreferences != null) {
      prefs = sharedPreferences;
    } else {
      _initSharedPreferences();
    }
    logger = customLogger ?? Logger(printer: PrettyPrinter());
  }

  // Getter for access token to be used by widgets
  String? get accessToken => _accessToken;

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> init() async {
    if (prefs == null) {
      await _initSharedPreferences();
    }
    await initSharedPreferences();
    await initUniLinks();
  }

  Future<void> initSharedPreferences() async {
    _accessToken = prefs.getString("access_token"); // Load the access token at initialization
  }

  Future<void> initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        handleLink(initialLink);
      }
    } on PlatformException {
      logger.e('Failed to get initial link.');
    }

    _sub = linkStream().listen((String? link) {
      if (link != null) {
        handleLink(link);
      }
    }, onError: (err) {
      logger.e('Failed to subscribe to link stream: $err');
    });
  }

  void handleLink(String link) {
    if (link.startsWith('itchio-app://oauth-callback')) {
      Uri uri = Uri.parse(link);
      Map<String, String> fragmentParameters = Uri.splitQueryString(uri.fragment);
      String? accessToken = fragmentParameters['access_token'];

      if (accessToken != null) {
        logger.i('token: $accessToken');
        handleAccessToken(accessToken);
      } else {
        logger.e('No access token found in the URL.');
      }
    } else {
      logger.e('Invalid link received: $link');
    }
  }

  Future<void> startOAuth() async {
    final Uri url = Uri.parse('https://itch.io/user/oauth?client_id=8277d34bebbf51289c9a9d2e77cea871&scope=profile&response_type=token&redirect_uri=itchio-app%3A%2F%2Foauth-callback');

    logger.i(url.toString());
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void handleAccessToken(String accessToken) {
    _accessToken = accessToken; // Update the access token
    saveAccessTokenToSharedPreferences(accessToken);
    notifyListeners(); // Notify listeners about the change
  }

  Future<void> saveAccessTokenToSharedPreferences(String accessToken) async {
    await prefs.setString('access_token', accessToken);
  }

  Future<String> getAccessToken() async {
    return _accessToken ?? "No access token found";
  }

  void logout() {
    _accessToken = null; // Clear the access token
    prefs.remove('access_token'); // Remove the token from shared preferences
    notifyListeners(); // Notify listeners about the change
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose(); // Call dispose on ChangeNotifier to clean up any listeners
  }
}

Future<String?> getInitialLinkImpl() => getInitialLink();
Stream<String?> linkStreamImpl() => linkStream;
