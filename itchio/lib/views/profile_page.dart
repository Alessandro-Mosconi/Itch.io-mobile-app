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
import '../widgets/game_card.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late Future<User> user;
  late Future<List<Game>> developedGames;
  late Future<List<PurchaseGame>> purchasedGames;
  final Logger logger = Logger(printer: PrettyPrinter());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUser();
  }

  void fetchUser() {
    final authService = Provider.of<OAuthService>(context, listen: false);
    final accessToken = authService.accessToken;

    if (accessToken == null) {
      user = Future.error('No access token found');
      return;
    }

    user = http
        .get(Uri.parse('https://itch.io/api/1/$accessToken/me'))
        .then((response) {
      if (response.statusCode == 200) {
        final fetchedUser = User(json.decode(response.body)["user"]);
        developedGames = fetchDevelopedGames(accessToken);
        purchasedGames = fetchPurchasedGames(accessToken);
        return fetchedUser;
      } else {
        throw Exception('Failed to load profile data');
      }
    }).catchError((error) {
      return Future.error(error.toString());
    });
  }

  Future<List<Game>> fetchDevelopedGames(String accessToken) async {
    final response = await http.get(Uri.parse('https://itch.io/api/1/$accessToken/my-games'));

    if (response.statusCode == 200) {
      return (json.decode(response.body)["games"] as List<dynamic>)
          .map((gameMap) => Game(gameMap))
          .toList();
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
      body: Consumer<OAuthService>(
        builder: (context, authService, child) {
          if (authService.accessToken == null) {
            return Center(
              child: ElevatedButton(
                onPressed: authService.startOAuth,
                child: Text('Authenticate'),
              ),
            );
          } else {
            return FutureBuilder<User>(
              future: user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
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
    );
  }

  Widget buildUserProfile(User user) {
    return Column(
      children: <Widget>[
        _buildProfileHeader(user),
        SizedBox(height: 20),
        buildUserTags(user),
        SizedBox(height: 20),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Developed Games"),
            Tab(text: "Purchased Games"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              buildGamesSection(developedGames),
              buildPurchasedGamesSection(purchasedGames),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        Text(
          user.displayName ?? "",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(user.coverUrl ?? ""),
        ),
        SizedBox(height: 20),
        Text(
          "@${user.username ?? ""}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: tags,
    );
  }

  Widget buildTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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

  Widget buildGamesSection(Future<List<Game>>? gamesFuture) {
    return FutureBuilder<List<Game>>(
      future: gamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return GameCard(game: snapshot.data![index]);
            },
          );
        } else {
          return Center(child: Text("No games found"));
        }
      },
    );
  }

  Widget buildPurchasedGamesSection(Future<List<PurchaseGame>>? gamesFuture) {
    return FutureBuilder<List<PurchaseGame>>(
      future: gamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              PurchaseGame purchasedGame = snapshot.data![index];
              return purchasedGame.game != null
                  ? GameCard(game: purchasedGame.game!)
                  : SizedBox.shrink();
            },
          );
        } else {
          return Center(child: Text("No games found"));
        }
      },
    );
  }
}
