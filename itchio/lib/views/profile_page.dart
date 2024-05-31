import 'package:flutter/material.dart';
import 'dart:convert';
import '../helperClasses/User.dart';
import '../services/oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'developed_games_page.dart';
import 'purchased_games_page.dart';
import 'settings_page.dart';  // Import the SettingsPage
import '../widgets/custom_app_bar.dart';  // Import the CustomAppBar

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<User>? user;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(  // Use the CustomAppBar with actions here
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
                      return Center(child: CircularProgressIndicator());
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
    final OAuthService authService = Provider.of<OAuthService>(context, listen: false);
    String? accessToken = authService.accessToken;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 100),  // Adjust height to place content below AppBar
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DevelopedGamesPage(accessToken: accessToken)),
              );
            },
            child: Text('Developed Games'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PurchasedGamesPage(accessToken: accessToken)),
              );
            },
            child: Text('Purchased Games'),
          ),
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
}
