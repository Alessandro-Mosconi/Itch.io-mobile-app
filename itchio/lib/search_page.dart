import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'custom_app_bar.dart';
import 'customIcons/custom_icon_icons.dart';
import 'helperClasses/Game.dart';
import 'helperClasses/User.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> searchResults;
  bool _searchPerformed = false;

  @override
  void initState() {
    super.initState();
    // Initialize with an empty Future
    searchResults = Future.value({"games": [], "users": []});
  }

  Future<Map<String, dynamic>> fetchSearchResults(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/search?search=$query'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load search results, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load search results');
      }
    } catch (error) {
      print('Error fetching search results: $error');
      throw Exception('Failed to load search results');
    }
  }

  void _performSearch() {
    setState(() {
      _searchPerformed = true;
      searchResults = fetchSearchResults(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for games or users...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          if (!_searchPerformed)
            Center(child: Text('Enter a search query to begin')),
          if (_searchPerformed)
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('FutureBuilder Error: ${snapshot.error}');
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    var data = snapshot.data!;
                    List<Game> games = (data['games'] as List).map((game) => Game(game)).toList();
                    List<User> users = (data['users'] as List).map((user) => User(user)).toList();

                    return ListView(
                      children: [
                        if (games.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...games.map((game) => GameTile(game: game)).toList(),
                        ],
                        if (users.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...users.map((user) => UserTile(user: user)).toList(),
                        ],
                      ],
                    );
                  } else {
                    return Center(child: Text("No results found"));
                  }
                },
              ),
            ),
        ],
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
                  game.imageurl ?? "https://via.placeholder.com/50", // Default image URL
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
                            game.title ?? "Default Title", // Default title
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          game.min_price == 0
                              ? Text(
                            "Free",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          )
                              : Text(
                            "${(game.min_price != null ? game.min_price! / 100 : 0).toStringAsFixed(2)} €", // Check for null
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(game.description ?? "No description", style: TextStyle(fontSize: 14)), // Default description
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
                _buildStatColumn("Views", game.views_count ?? 0, Colors.red), // Default views count
                _buildStatColumn("Downloads", game.downloads_count ?? 0, Colors.green), // Default downloads count
                _buildStatColumn("Purchases", game.purchases_count ?? 0, Colors.blue), // Default purchases count
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


class UserTile extends StatelessWidget {
  final User user;

  const UserTile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Image.network(
              user.avatar ?? "https://via.placeholder.com/50", // Default image URL
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName ?? "Default Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Default name
                Text('${user.numberOfProjects ?? 0} Projects', style: TextStyle(fontSize: 14)), // Default projects count
              ],
            ),
          ],
        ),
      ),
    );
  }
}

