import 'dart:convert';

import 'package:logger/logger.dart';


import 'game.dart';

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



