import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:itchio/helperClasses/SavedSearch.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_app_bar.dart';
import 'package:http/http.dart' as http;

import 'helperClasses/Game.dart';

final Logger logger = Logger(printer: PrettyPrinter());

bool checkTimestamp(int? timestamp){
  // 172800000 = 2 days in ms
  return (timestamp == null) || ((timestamp + 172800000) > DateTime.now().millisecondsSinceEpoch);
}

Future<List<SavedSearch>> fetchSavedSearch() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("access_token");

  if(prefs.getString("saved_searches") != null && checkTimestamp(prefs.getInt("saved_searches_timestamp"))){

    String body = prefs.getString("saved_searches")!;

    List<dynamic>? results = json.decode(body);

    List<SavedSearch> savedSearches = results?.map((r) => SavedSearch(r)).toList() ?? [];

    return savedSearches;
  }

  final response = await http.post(
    Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/get_saved_search_carousel'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'token': token}),
  );

  if (response.statusCode == 200) {
    List<dynamic>? results = json.decode(response.body);

    List<SavedSearch> savedSearches = results?.map((r) => SavedSearch(r)).toList() ?? [];
    prefs.setString("saved_searches", response.body);
    prefs.setInt("saved_searches_timestamp", DateTime.now().millisecondsSinceEpoch);

    return savedSearches;
  } else {
    throw Exception('Failed to load saved search results');
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SavedSearch>> futureSavedSearches;

  @override
  void initState() {
    super.initState();
    futureSavedSearches = fetchSavedSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<SavedSearch>>(
        future: futureSavedSearches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load saved search results'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved searches found'));
          } else {
            List<SavedSearch> savedSearches = snapshot.data!;
            return ListView.builder(
              itemCount: savedSearches.length,
              itemBuilder: (context, index) {
                SavedSearch search = savedSearches[index];
                return CarouselCard(
                  title: kebabToCapitalized(search.type ?? ''),
                  subtitle: search.filters ?? '',
                  items: search.items ?? [],
                );
              },
            );
          }
        },
      ),
    );
  }
}
String kebabToCapitalized(String kebab) {
  List<String> words = kebab.split('-');

  String capitalized = words.map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');

  return capitalized;
}
// Widget per il carosello
class CarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Game> items;

  CarouselCard({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                Game game = items[index];
                return Container(
                  width: 150,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(game.imageurl ?? '', fit: BoxFit.cover, width: 150, height: 120),
                      SizedBox(height: 5),
                      Text(game.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}