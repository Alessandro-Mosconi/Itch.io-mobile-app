import 'package:flutter/material.dart';
import 'dart:convert';
import '../helperClasses/User.dart';
import '../helperClasses/Game.dart';
import '../helperClasses/PurchaseGame.dart';
import '../services/oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'settings_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/game_tile.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<User>? user;
  Future<List<Game>>? developedGames;
  Future<List<PurchaseGame>>? purchasedGames;
  final Logger logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      String? accessToken = Provider.of<OAuthService>(context, listen: false).accessToken;
      if (accessToken == null) {
        setState(() {
          user = Future.error('No access token found');
        });
        return;
      }

      final response = await http.get(Uri.parse('https://itch.io/api/1/$accessToken/me'));

      if (response.statusCode == 200) {
        User fetchedUser = User(json.decode(response.body)["user"]);
        setState(() {
          user = Future.value(fetchedUser);
          developedGames = fetchDevelopedGames(accessToken);
          purchasedGames = fetchPurchasedGames(accessToken);
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      setState(() {
        user = Future.error(e.toString());
      });
    }
  }

  Future<List<Game>> fetchDevelopedGames(String accessToken) async {
    final response = await http.get(Uri.parse('https://itch.io/api/1/$accessToken/my-games'));

    if (response.statusCode == 200) {
      return (json.decode(response.body)["games"] as List<dynamic>).map((gameMap) => Game(gameMap)).toList();
    } else {
      throw Exception('Failed to load developed games');
    }
  }

  Future<List<PurchaseGame>> fetchPurchasedGames(String accessToken) async {
    final response = await http.get(Uri.parse('https://itch.io/api/1/$accessToken/my-owned-keys'));

    if (response.statusCode == 200) {
      return (json.decode(response.body)["owned_keys"] as List<dynamic>)
          .map((gameMap) => PurchaseGame(gameMap))
          .toList();
    } else {
      throw Exception('Failed to load purchased games');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<OAuthService>(
            builder: (context, authService, child) {
              if (authService.accessToken == null) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      authService.startOAuth();
                    },
                    child: Text('Authenticate'),
                  ),
                );
              } else {
                return FutureBuilder<User>(
                  future: user,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      return buildUserProfile(snapshot.data!);
                    } else {
                      return Center(child: Text("Loading profile..."));
                    }
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildUserProfile(User user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            user.displayName ?? "",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(user.coverUrl ?? ""),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "@" + (user.username ?? ""),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          buildUserTags(user),
          SizedBox(height: 20),
          buildGamesSection("Developed Games", developedGames),
          SizedBox(height: 20),
          buildPurchasedGamesSection("Purchased Games", purchasedGames),
        ],
      ),
    );
  }

  Widget buildUserTags(User user) {
    List<Widget> tags = [];
    if (user.isDeveloper ?? false) {
      tags.add(buildTag("Developer", Colors.green));
    }
    if (user.isGamer ?? false) {
      tags.add(buildTag("Gamer", Colors.blue));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tags,
    );
  }

  Widget buildTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget buildGamesSection(String title, Future<List<Game>>? gamesFuture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        FutureBuilder<List<Game>>(
          future: gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox.shrink(); // Remove loading indicator
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return GameTile(game: snapshot.data![index]);
                },
              );
            } else {
              return Center(child: Text("No games found"));
            }
          },
        ),
      ],
    );
  }

  Widget buildPurchasedGamesSection(String title, Future<List<PurchaseGame>>? gamesFuture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        FutureBuilder<List<PurchaseGame>>(
          future: gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox.shrink(); // Remove loading indicator
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  PurchaseGame purchasedGame = snapshot.data![index];
                  return purchasedGame.game != null
                      ? GameTile(game: purchasedGame.game!)
                      : SizedBox.shrink();
                },
              );
            } else {
              return Center(child: Text("No games found"));
            }
          },
        ),
      ],
    );
  }
}
