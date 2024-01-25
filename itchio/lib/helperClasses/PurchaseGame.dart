import 'dart:convert';

import 'package:itchio/helperClasses/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:logger/logger.dart';

import 'package:url_launcher/url_launcher.dart';

import 'Game.dart';

class PurchaseGame {
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  Game? game;
  int? game_id;
  int? purchase_id;
  String? created_at;
  String? updated_at;
  int? id;
  int? download;

  // Not in the interface, since this is a constructor.
  purchaseFromJson(String jsonGame){
    var data = json.decode(jsonGame);

    PurchaseGame(data);
  }

  PurchaseGame(Map<String, dynamic> data){
    game_id = data['game_id'];
    purchase_id = data['purchase_id'];
    created_at = data['created_at'];
    updated_at = data['updated_at'];
    id = data['id'];
    download = data['download'];
    game = Game(data['game']);
  }

}



