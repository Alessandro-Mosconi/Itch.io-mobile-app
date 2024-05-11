import 'package:flutter/material.dart';
import 'dart:convert';
import 'helperClasses/Game.dart';
import 'oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'customIcons/custom_icon_icons.dart';

class DevelopedGamesPage extends StatefulWidget {
  final String? accessToken;

  const DevelopedGamesPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _DevelopedGamesPageState createState() => _DevelopedGamesPageState();
}

class _DevelopedGamesPageState extends State<DevelopedGamesPage> {
  late Future<List<Game>> gameList;
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );


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
        title: Text('My Games Page'),
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
                      // Margine a tutto il contenuto
                      Container(
                        margin: EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Immagine del gioco con BoxFit.contain
                            Image.network(
                              game.cover_url ?? "URL_default",
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 8),
                            // Titolo e descrizione del gioco con prezzo
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Row per visualizzare il titolo e il prezzo accanto
                                Row(
                                  children: [
                                    Text(game.title ?? "Default Title", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    game.min_price == 0
                                        ? Text("Free", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green))
                                        : Text("${(game.min_price! / 100).toStringAsFixed(2)} €", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(game.short_text ?? "No description", style: TextStyle(fontSize: 14)),
                                SizedBox(height: 8),
                                // Row per le icone degli OS
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
                          ],
                        ),
                      ),
                      SizedBox(height: 8), // Spazio aggiunto tra l'immagine e il testo
                      // Numeri in tre colonne con margine e colore
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            // Views
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Circonferenza vuota attorno al numero "Views"
                                  Container(
                                    width: 80, // Larghezza aumentata
                                    height: 80, // Altezza aumentata
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.red, width: 2),
                                    ),
                                    child: Center(
                                      child: Text("${game.views_count}", style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text("Views", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            // Downloads
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Circonferenza vuota attorno al numero "Downloads"
                                  Container(
                                    width: 80, // Larghezza aumentata
                                    height: 80, // Altezza aumentata
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.green, width: 2),
                                    ),
                                    child: Center(
                                      child: Text("${game.downloads_count}", style: TextStyle(fontSize: 30, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text("Downloads", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            // Purchases
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Circonferenza vuota attorno al numero "Purchases"
                                  Container(
                                    width: 80, // Larghezza aumentata
                                    height: 80, // Altezza aumentata
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.blue, width: 2),
                                    ),
                                    child: Center(
                                      child: Text("${game.purchases_count}", style: TextStyle(fontSize: 30, color: Colors.blue, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Testo "Purchases" senza prezzo
                                  Text("Purchases", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
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