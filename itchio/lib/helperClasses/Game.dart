import 'dart:convert';
import 'package:itchio/helperClasses/User.dart';

class Game {
  int? views_count;
  String? url;
  int? id;
  String? short_text;
  int? min_price;
  String? type;
  bool? p_windows;
  bool? p_linux;
  bool? p_osx;
  bool? p_android;
  String? title;
  String? published_at;
  bool? can_be_bought;
  String? classification;
  String? created_at;
  bool? in_press_system;
  String? cover_url;
  int? purchases_count;
  bool? published;
  int? downloads_count;
  String? has_demo;
  User? user;
  String? still_cover_url;
  String? description;
  String? imageurl;
  String? author;

  // Constructor for Game class to handle JSON data
  Game(Map<String, dynamic> data) {
    views_count = data['views_count'];
    url = data['url'];
    id = data['id'];
    short_text = data['short_text'];
    min_price = data['min_price'];
    type = data['type'];
    p_windows = data['p_windows'];
    p_linux = data['p_linux'];
    p_osx = data['p_osx'];
    p_android = data['p_android'];
    title = data['title'];
    published_at = data['published_at'];
    can_be_bought = data['can_be_bought'];
    classification = data['classification'];
    created_at = data['created_at'];
    in_press_system = data['in_press_system'];
    cover_url = data['cover_url'];
    purchases_count = data['purchases_count'];
    published = data['published'];
    downloads_count = data['downloads_count'];
    still_cover_url = data['still_cover_url'];
    user = data['user'] != null ? User(data['user']) : null;
    description = data['description'];
    imageurl = data['imageurl'];
    author = data['author'];
  }

  // Additional constructor to handle JSON string
  Game.fromJson(String jsonGame) {
    var data = json.decode(jsonGame);
    views_count = data['views_count'];
    url = data['url'];
    id = data['id'];
    short_text = data['short_text'];
    min_price = data['min_price'];
    type = data['type'];
    p_windows = data['p_windows'];
    p_linux = data['p_linux'];
    p_osx = data['p_osx'];
    p_android = data['p_android'];
    title = data['title'];
    published_at = data['published_at'];
    can_be_bought = data['can_be_bought'];
    classification = data['classification'];
    created_at = data['created_at'];
    in_press_system = data['in_press_system'];
    cover_url = data['cover_url'];
    purchases_count = data['purchases_count'];
    published = data['published'];
    downloads_count = data['downloads_count'];
    still_cover_url = data['still_cover_url'];
    user = data['user'] != null ? User(data['user']) : null;
    description = data['description'];
    imageurl = data['imageurl'];
    author = data['author'];
  }
}




