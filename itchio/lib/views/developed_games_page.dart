import 'package:flutter/material.dart';
import 'dart:convert';
import '../helperClasses/Game.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../customIcons/custom_icon_icons.dart';

class DevelopedGamesPage extends StatefulWidget {
  final String? accessToken;

  const DevelopedGamesPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _DevelopedGamesPageState createState() => _DevelopedGamesPageState();
}

class _DevelopedGamesPageState extends State<DevelopedGamesPage> {
  late Future<List<Game>> gameList;
  final Logger logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    gameList = fetchGameListData();
  }

  Future<List<Game>> fetchGameListData() async {
    String? accessToken = widget.accessToken;

    final response = await http.get(
        Uri.parse('https://itch.io/api/1/$accessToken/my-games')
    );

    if (response.statusCode == 200) {
      List<Game> gameList = (json.decode(response.body)["games"] as List<dynamic>).map((gameMap) => Game(gameMap)).toList();
      return gameList;
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Developed Games'),
      ),
      body: FutureBuilder<List<Game>>(
        future: gameList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            List<Game> games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                Game game = games[index];
                return GameTile(game: game);
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

class GameTile extends StatelessWidget {
  final Game game;

  const GameTile({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            game.title ?? "Default Title",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          game.min_price == 0
                              ? Text(
                            "Free",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          )
                              : Text(
                            "${(game.min_price! / 100).toStringAsFixed(2)} €",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(game.short_text ?? "No description", style: TextStyle(fontSize: 14)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          if (game.p_windows ?? false) Icon(CustomIcon.windows, size: 16, color: Colors.grey),
                          if (game.p_osx ?? false) Icon(Icons.apple, size: 24, color: Colors.grey),
                          if (game.p_linux ?? false) Icon(CustomIcon.linux, size: 16, color: Colors.grey),
                          if (game.p_android ?? false) Icon(Icons.android, size: 24, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildStatColumn("Views", game.views_count ?? 0, Colors.red),
                _buildStatColumn("Downloads", game.downloads_count ?? 0, Colors.green),
                _buildStatColumn("Purchases", game.purchases_count ?? 0, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              "$count",
              style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
