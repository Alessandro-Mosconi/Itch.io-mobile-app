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

class CarouselCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Game> items;

  CarouselCard({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  _CarouselCardState createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  bool isNotificationEnabled = false;
  final Logger logger = Logger();

  void _toggleNotification() {
    setState(() {
      isNotificationEnabled = !isNotificationEnabled;
      logger.i('notifica');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isNotificationEnabled ? Icons.notifications_active : Icons.notification_add_outlined,
                    color: isNotificationEnabled ? Colors.amber : Colors.grey,
                  ),
                  onPressed: _toggleNotification,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,  // Increased height for larger images
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                Game game = widget.items[index];
                return Container(
                  width: 160,  // Increased width
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          game.imageurl ?? '',
                          fit: BoxFit.cover,
                          width: 160,
                          height: 140,  // Increased height
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        game.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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