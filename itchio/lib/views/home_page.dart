import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:itchio/providers/search_bookmark_provider.dart';
import 'package:itchio/widgets/saved_search_list.dart'; // Ensure this import is correct
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/favorite_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;

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
    List<dynamic> results = json.decode(body);
    return results.map((r) => SavedSearch(r)).toList();
  }

  final response = await http.post(
    Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/get_saved_search_carousel'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'token': token}),
  );

  if (response.statusCode == 200) {
    List<dynamic> results = json.decode(response.body);
    prefs.setString("saved_searches", response.body);
    prefs.setInt("saved_searches_timestamp", DateTime.now().millisecondsSinceEpoch);
    return results.map((r) => SavedSearch(r)).toList();
  } else {
    throw Exception('Failed to load saved search results');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    initFavorites(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<List<SavedSearch>>(
        future: futureSavedSearches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load saved search results'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved searches found'));
          } else {
            return SavedSearchList(savedSearches: snapshot.data!);
          }
        },
      ),
    );
  }

  Future<void> initFavorites(BuildContext context) async {
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final searchBookmarkProvider = Provider.of<SearchBookmarkProvider>(context, listen: false);
    await Future.wait([
      favoriteProvider.fetchFavoriteGames(),
      favoriteProvider.fetchFavoriteJams(),
      searchBookmarkProvider.fetchBookmarks(),
    ]);
  }
}
