import 'package:flutter/material.dart';
import 'dart:convert';
import 'helperClasses/Game.dart';
import 'helperClasses/PurchaseGame.dart';
import 'oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'game_tile.dart'; // Import the external GameTile widget

class PurchasedGamesPage extends StatefulWidget {
  final String? accessToken;

  const PurchasedGamesPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _PurchasedGamesPageState createState() => _PurchasedGamesPageState();
}

class _PurchasedGamesPageState extends State<PurchasedGamesPage> {
  late Future<List<PurchaseGame>> gameList;
  final Logger logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    gameList = fetchGameListData();
  }

  Future<List<PurchaseGame>> fetchGameListData() async {
    final response = await http.get(
      Uri.parse('https://itch.io/api/1/${widget.accessToken}/my-owned-keys'),
    );

    if (response.statusCode == 200) {
      List<PurchaseGame> gameList = (json.decode(response.body)["owned_keys"] as List<dynamic>)
          .map((gameMap) => PurchaseGame(gameMap))
          .toList();
      return gameList;
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchased Games'),
      ),
      body: FutureBuilder<List<PurchaseGame>>(
        future: gameList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            List<PurchaseGame> games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                PurchaseGame purchasedGame = games[index];
                return purchasedGame.game != null
                    ? GameTile(game: purchasedGame.game!)
                    : SizedBox.shrink();
              },
            );
          } else {
            return Center(child: Text("No profile data found"));
          }
        },
      ),
    );
  }
}
