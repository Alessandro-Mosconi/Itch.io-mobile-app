import 'dart:convert';

class User {
  String? username;
  String? url;
  int? id;
  String? displayName;
  String? coverUrl;
  bool? isDeveloper;
  bool? isGamer;
  String? avatar;
  int? numberOfProjects;

  // Constructor for User class to handle JSON data
  User(Map<String, dynamic> data) {
    username = data['username'];
    url = data['url'];
    id = data['id'];
    displayName = data['display_name'];
    coverUrl = data['cover_url'];
    isGamer = data['gamer'];
    isDeveloper = data['developer'];
    avatar = data['img'];
    numberOfProjects = int.tryParse(data['number_of_projects'] ?? '0');
  }

  // Additional constructor to handle JSON string
  User.fromJson(String jsonUser) {
    var data = json.decode(jsonUser);
    username = data['username'];
    url = data['url'];
    id = data['id'];
    displayName = data['display_name'];
    coverUrl = data['cover_url'];
    isGamer = data['gamer'];
    isDeveloper = data['developer'];
    avatar = data['img'];
    numberOfProjects = int.tryParse(data['number_of_projects'] ?? '0');
  }
}



