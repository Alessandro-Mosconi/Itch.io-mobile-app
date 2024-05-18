import 'package:flutter/material.dart';
import 'dart:convert';
import 'helperClasses/Game.dart';
import 'helperClasses/PurchaseGame.dart';
import 'oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

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
    String? accessToken = widget.accessToken;

    final response = await http.get(
        Uri.parse('https://itch.io/api/1/$accessToken/my-owned-keys')
    );

    if (response.statusCode == 200) {
      List<PurchaseGame> gameList = (json.decode(response.body)["owned_keys"] as List<dynamic>).map((gameMap) => PurchaseGame(gameMap)).toList();
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
                return PurchaseGameTile(purchasedGame: purchasedGame);
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

class PurchaseGameTile extends StatelessWidget {
  final PurchaseGame purchasedGame;

  const PurchaseGameTile({Key? key, required this.purchasedGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Game? game = purchasedGame.game;
    if (game == null) {
      return SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.network(
                  game.cover_url ?? "URL_default",
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        game.title ?? "Default Title",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(game.short_text ?? "No description", style: TextStyle(fontSize: 14)),
                      SizedBox(height: 8),
                      Text(
                        "${(game.min_price! / 100).toStringAsFixed(2)} €" ?? "No description",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
