import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/User.dart';
import '../models/game.dart';
import '../models/purchased_game.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {

  Future<User> fetchUser(String accessToken) {

    return http
        .get(Uri.parse('https://itch.io/api/1/$accessToken/me'))
        .then((response) {
      if (response.statusCode == 200) {
        final fetchedUser = User(json.decode(response.body)["user"]);
        return fetchedUser;
      } else {
        throw Exception('Failed to load profile data');
      }
    });
  }

  Future<List<Game>> fetchDevelopedGames(String accessToken) async {
    final response = await http.get(Uri.parse('https://itch.io/api/1/$accessToken/my-games'));

    if (response.statusCode == 200) {
      if(json.decode(response.body)["games"] is List<dynamic>){
        return (json.decode(response.body)["games"] as List<dynamic>)
            .map((gameMap) => Game(gameMap))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load developed games');
    }
  }

  Future<List<PurchaseGame>> fetchPurchasedGames(String accessToken) async {
    final response = await http.get(Uri.parse('https://itch.io/api/1/$accessToken/my-owned-keys'));

    if (response.statusCode == 200) {
      if(json.decode(response.body)["owned_keys"] is List<dynamic>){
        return (json.decode(response.body)["owned_keys"] as List<dynamic>)
            .map((gameMap) => PurchaseGame(gameMap))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load purchased games');
    }
  }

}
