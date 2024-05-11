import 'package:flutter/material.dart';
import 'dart:convert';
import 'helperClasses/User.dart';
import 'oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'developed_games_page.dart';
import 'purchased_games_page.dart';


class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> user;
  final Logger logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    user = fetchUser();
  }

  Future<User> fetchUser() async {
    String? accessToken = Provider.of<OAuthService>(context, listen: false).accessToken;
    final response = await http.get(Uri.parse('https://itch.io/api/1/$accessToken/me'));

    if (response.statusCode == 200) {
      User user = User(json.decode(response.body)["user"]);
      return user;
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return buildUserProfile(snapshot.data!);
          } else {
            return Center(child: Text("No profile data found"));
          }
        },
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DevelopedGamesPage(accessToken: accessToken)),
              );
            },
            child: Text('My Games'),
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
