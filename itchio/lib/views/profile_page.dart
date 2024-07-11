import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import '../models/User.dart';
import '../models/game.dart';
import '../models/purchased_game.dart';
import '../services/oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'settings_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/game_card.dart'; // Import the GameCard widget
import '../widgets/developed_game_card.dart'; // Import the DevelopedGameCard widget

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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

  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    final isTablet = diagonal > 1500.0; // Adjust this value based on your definition of a tablet
    return isTablet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
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
                child: const Text('Authenticate'),
              ),
            );
          } else {
            return FutureBuilder<User>(
              future: user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  return buildUserProfile(snapshot.data!);
                } else {
                  return const Center(child: Text("Loading profile..."));
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
        const SizedBox(height: 20),
        buildUserTags(user),
        const SizedBox(height: 20),
        Expanded(
          child: isTablet(context) ? buildTabletLayout() : buildTabLayout(),
        ),
      ],
    );
  }

  Widget buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Adjust the padding as needed
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Developed Games',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10), // Space between title and content
                  Expanded(child: buildGamesSection(developedGames)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40), // Increase the gap between the columns
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Purchased Games',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10), // Space between title and content
                  Expanded(child: buildPurchasedGamesSection(purchasedGames)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget buildTabLayout() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(user.coverUrl ?? ""),
        ),
        const SizedBox(height: 20),
        Text(
          "@${user.username ?? ""}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
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
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget buildGamesSection(Future<List<Game>>? gamesFuture) {
    return FutureBuilder<List<Game>>(
        future: gamesFuture,
        builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return DevelopedGameCard(game: snapshot.data![index]);
          },
        );
      } else {
        return const Center(child: Text("No games found"));
      }
        },
    );
  }

  Widget buildPurchasedGamesSection(Future<List<PurchaseGame>>? gamesFuture) {
    return FutureBuilder<List<PurchaseGame>>(
      future: gamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              PurchaseGame purchasedGame = snapshot.data![index];
              return purchasedGame.game != null
                  ? GameCard(game: purchasedGame.game!)
                  : const SizedBox.shrink();
            },
          );
        } else {
          return const Center(child: Text("No games found"));
        }
      },
    );
  }
}

