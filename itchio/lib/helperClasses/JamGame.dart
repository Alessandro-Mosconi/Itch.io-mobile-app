import 'dart:convert';

import 'Game.dart';

class JamGame {
  int? ratingCount;
  int? coolness;
  int? id;
  Game? game;
  String? url;
  DateTime? createdAt;
  List<String>? fieldResponses;

  JamGame(Map<String, dynamic> data) {
    ratingCount = data['rating_count'];
    coolness = data['coolness'];
    id = data['id'];
    game = Game(data['game']);
    url = data['url'];
    createdAt = DateTime.parse(data['created_at']);
    fieldResponses = List<String>.from(data['field_responses'] ?? []);
  }
  JamGame.fromJson(String jsonJam) {
    var data = json.decode(jsonJam);
    coolness = data['coolness'];
    id = data['id'];
    game = Game(data['game']);
    url = data['url'];
    createdAt = DateTime.parse(data['created_at']);
    fieldResponses = List<String>.from(data['field_responses'] ?? []);
  }
}