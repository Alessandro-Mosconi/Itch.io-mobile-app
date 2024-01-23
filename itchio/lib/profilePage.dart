import 'package:flutter/material.dart';
import 'dart:convert';
import 'oauth.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String accessToken;
  const ProfilePage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileData> profileData;

  @override
  void initState() {
    super.initState();
    profileData = fetchProfileData();
  }

  Future<ProfileData> fetchProfileData() async {
    // Retrieve the access token from SharedPreferences
    String accessToken = await oAuthService.getAccessToken();

    final response = await http.get(
      Uri.parse('https://itch.io/api/1/KEY/me'), // endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _username = data['user']['username'];
      _coverUrl = data['user']['cover_url'];
      // Use _username and _coverUrl as needed
      return ProfileData(
        profileName: _username,
        profilePictureUrl: _coverUrl,
      );
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
      body: FutureBuilder<ProfileData>(
        future: profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Image.network(snapshot.data!.profilePictureUrl),
                Text(snapshot.data!.profileName),
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

class ProfileData {
  final String profileName;
  final String profilePictureUrl;

  ProfileData({required this.profileName, required this.profilePictureUrl});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      profileName: json['username'] ?? 'No username', // Use actual JSON field
      profilePictureUrl: json['cover_url'] ?? '', // Use actual JSON field
    );
  }
}
