import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:logger/logger.dart';

import 'package:url_launcher/url_launcher.dart';



class OAuthService {
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  late SharedPreferences prefs;
  StreamSubscription? _sub;

  Future<void> init() async {
    await initSharedPreferences();
    await initUniLinks();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
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

    _sub = linkStream.listen((String? link) {
      if (link != null) {
        handleLink(link);
      }
    }, onError: (err) {
      logger.e('Failed to subscribe to link stream: $err');
    });
  }

  void handleLink(String link) {
    if (link.startsWith('itchio-app://oauth-callback')) {

      // Extract and process the token or authorization code from the link
      // Continue with OAuth process
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

  void startOAuth() async {
    final Uri url = Uri.parse(
        'https://itch.io/user/oauth?client_id=8277d34bebbf51289c9a9d2e77cea871&scope=profile&response_type=token&redirect_uri=itchio-app%3A%2F%2Foauth-callback');
    logger.e('ciao');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void handleAccessToken(String accessToken) {
    saveAccessTokenToSharedPreferences(accessToken);
  }

  void saveAccessTokenToSharedPreferences(String accessToken) async {
    await prefs.setString('access_token', accessToken);
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token") ?? "No access token found";
  }

  void dispose() {
    _sub?.cancel();
  }

}



