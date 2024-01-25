import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:logger/logger.dart';

import 'package:url_launcher/url_launcher.dart';

class User {
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  String? username;
  String? url;
  int? id;
  String? displayName;
  String? coverUrl;

  // Not in the interface, since this is a constructor.
  UserFromJson(String jsonUser){

    var data = json.decode(jsonUser);

    username = data['username'];
    url = data['url'];
    id = data['id'];
    displayName = data['display_name'];
    coverUrl = data['cover_url'];
  }

  User(Map<String, dynamic> data){

    username = data['username'];
    url = data['url'];
    id = data['id'];
    displayName = data['display_name'];
    coverUrl = data['cover_url'];
  }

}



