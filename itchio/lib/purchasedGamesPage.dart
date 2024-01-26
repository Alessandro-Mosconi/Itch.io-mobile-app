import 'package:flutter/material.dart';
import 'dart:convert';
import 'helperClasses/Game.dart';
import 'helperClasses/PurchaseGame.dart';
import 'oauth.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class PurchasedGamesPage extends StatefulWidget {

  final String accessToken;
  const PurchasedGamesPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _PurchasedGamesPageState createState() => _PurchasedGamesPageState();
}

class _PurchasedGamesPageState extends State<PurchasedGamesPage> {
  late Future<List<PurchaseGame>> gameList;
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );
  final OAuthService _oAuthService = OAuthService();

  @override
  void initState() {
    super.initState();
    gameList = fetchGameListData();
  }

  Future<List<PurchaseGame>> fetchGameListData() async {
    String accessToken = await _oAuthService.getAccessToken();

    final response = await http.get(
      Uri.parse('https://itch.io/api/1/$accessToken/my-owned-keys')
    );

    if (response.statusCode == 200) {
      List<PurchaseGame> gameList = (json.decode(response.body)["owned_keys"]  as List<dynamic>).map((gameMap) => PurchaseGame(gameMap)).toList();
      return gameList;
    } else {
    throw Exception('Failed to load profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchased Game Page'),
      ),
      body: FutureBuilder<List<PurchaseGame>>(
        future: gameList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            List<PurchaseGame> games = snapshot.data!;

            return Column(
              children: <Widget>[
                for (PurchaseGame purchasedGame in games)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(purchasedGame.game?.title ?? "Default Title", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(purchasedGame.game?.short_text ?? "No description", style: TextStyle(fontSize: 14)),
                      Text("${purchasedGame.game!.min_price!/100} euro" ?? "No description", style: TextStyle(fontSize: 14)),
                      SizedBox(height: 16), // Spacing between each game
                    ],
                  ),
              ],
            );
          } else {
            return Text("No profile data found");
          }
        },
      ),
    );
  }
}