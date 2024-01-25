import 'package:flutter/material.dart';
import 'dart:convert';
import 'helperClasses/Game.dart';
import 'oauth.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class MyGamesPage extends StatefulWidget {

  final String accessToken;
  const MyGamesPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _MyGamesPageState createState() => _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
  late Future<List<Game>> gameList;
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );
  final OAuthService _oAuthService = OAuthService();

  @override
  void initState() {
    super.initState();
    gameList = fetchGameListData();
  }

  Future<List<Game>> fetchGameListData() async {
    String accessToken = await _oAuthService.getAccessToken();

    final response = await http.get(
      Uri.parse('https://itch.io/api/1/$accessToken/my-games')
    );

    if (response.statusCode == 200) {
      List<Game> gameList = (json.decode(response.body)["games"]  as List<dynamic>).map((gameMap) => Game(gameMap)).toList();
      return gameList;
    } else {
    throw Exception('Failed to load profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: FutureBuilder<List<Game>>(
        future: gameList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            List<Game> games = snapshot.data!;

            return Column(
              children: <Widget>[
                for (Game game in games)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(game.title ?? "Default Title", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(game.short_text ?? "No description", style: TextStyle(fontSize: 14)),
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