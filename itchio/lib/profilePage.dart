import 'package:flutter/material.dart';
import 'dart:convert';
import 'helperClasses/User.dart';
import 'oauth_service.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ProfilePage extends StatefulWidget {
  final String accessToken;
  const ProfilePage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> user;
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    user = fetchUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<User> fetchUser() async {

    // Retrieve the access token from SharedPreferences
    String accessToken = widget.accessToken;

    final response = await http.get(
      Uri.parse('https://itch.io/api/1/$accessToken/me')
    );

    if (response.statusCode == 200) {

      User user = User(json.decode(response.body)["user"]);

      // Use _username and _coverUrl as needed
      return user;
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
      body: FutureBuilder<User>(
        future: user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    snapshot.data!.displayName ?? "",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(snapshot.data!.coverUrl ?? ""),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "@" + (snapshot.data!.username ?? ""),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    snapshot.data!.url ?? "",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (snapshot.data!.isDeveloper ?? false)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "Sviluppatore",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      if (snapshot.data!.isGamer ?? false)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "Gamer",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );

          } else {
            return Text("No profile data found");
          }
        },
      ),
    );
  }
}

