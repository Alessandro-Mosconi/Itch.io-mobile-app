import 'package:flutter/material.dart';
import 'package:itchio/providers/user_provider.dart';
import 'dart:math';
import '../models/user.dart';
import '../models/game.dart';
import '../models/purchased_game.dart';
import '../services/oauth_service.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'settings_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/game_card.dart';
import '../widgets/developed_game_card.dart';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final authService = Provider.of<OAuthService>(context, listen: false);
    final accessToken = authService.accessToken;

    if (accessToken == null) {
      developedGames = Future.value([]);
      purchasedGames = Future.value([]);
      return;
    } else {
      user = userProvider.fetchUser(accessToken);
      developedGames = userProvider.fetchDevelopedGames(accessToken);
      purchasedGames = userProvider.fetchPurchasedGames(accessToken);
    }
  }

  bool isTabletAndLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    final isTablet = diagonal > 1000.0;
    final isLandscape = size.width > size.height;
    return isTablet && isLandscape;
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
                } else if (snapshot.hasData) {
                  return buildUserProfile(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  return const Center(child: Text("No user found"));
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget buildUserProfile(User user) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildProfileHeader(user),
          const SizedBox(height: 20),
          buildUserTags(user),
          const SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: isTabletAndLandscape(context) ? buildTabletLayout() : buildTabLayout(),
          ),
        ],
      ),
    );
  }

  Widget buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  const SizedBox(height: 10),
                  Expanded(child: buildGamesSection(developedGames)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
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
                  const SizedBox(height: 10),
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
          return isTabletAndLandscape(context)?
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return DevelopedGameCard(game: snapshot.data![index]);
            },
          )
          : ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return DevelopedGameCard(game: snapshot.data![index]);
            },
          );
        } else {
          return const Center(child: Text("No developed games found"));
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
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              PurchaseGame purchasedGame = snapshot.data![index];
              return purchasedGame.game != null
                  ? GameCard(game: purchasedGame.game!)
                  : const SizedBox.shrink();
            },
          );
        } else {
          return const Center(child: Text("No purchased games found"));
        }
      },
    );
  }
}
