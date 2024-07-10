import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itchio/models/saved_search.dart';
import 'package:itchio/providers/search_bookmark_provider.dart';
import 'package:itchio/widgets/saved_search_list.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/favorite_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

final Logger logger = Logger(printer: PrettyPrinter());

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

// single ticker provider is needed for the box animations
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late Future<List<SavedSearch>> futureSavedSearches;
  late AnimationController _animationController;

  static const Duration cacheValidDuration = Duration(days: 2);
  static const String savedSearchesKey = "saved_searches";
  static const String savedSearchesTimestampKey = "saved_searches_timestamp";

  @override
  void initState() {
    super.initState();
    futureSavedSearches = fetchSavedSearch();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<SavedSearch>> fetchSavedSearch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      if (_isCacheValid(prefs)) {
        return _getFromCache(prefs);
      }

      final response = await http.post(
        Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/get_saved_search_carousel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        List<dynamic> results = json.decode(response.body);
        _saveToCache(prefs, response.body);
        return results.map((r) => SavedSearch(r)).toList();
      } else {
        throw Exception('Failed to load saved search results');
      }
    } catch (e) {
      logger.e('Error fetching saved searches: $e');
      rethrow;
    }
  }

  bool _isCacheValid(SharedPreferences prefs) {
    final timestamp = prefs.getInt(savedSearchesTimestampKey);
    return timestamp != null &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)) < cacheValidDuration;
  }

  List<SavedSearch> _getFromCache(SharedPreferences prefs) {
    String body = prefs.getString(savedSearchesKey)!;
    List<dynamic> results = json.decode(body);
    return results.map((r) => SavedSearch(r)).toList();
  }

  void _saveToCache(SharedPreferences prefs, String data) {
    prefs.setString(savedSearchesKey, data);
    prefs.setInt(savedSearchesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _refreshSavedSearches() async {
    setState(() {
      futureSavedSearches = fetchSavedSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshSavedSearches,
        child: FutureBuilder<List<SavedSearch>>(
          future: futureSavedSearches,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyStateWidget();
            } else {
              return SavedSearchList(savedSearches: snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Oops! Something went wrong.', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(error, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshSavedSearches,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/81ee35fc-7d8f-4356-81fc-801e078d7014/jETcdSHcKj.json',
              controller: _animationController,
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 24),
            Text(
              'No saved searches yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Build your feed saving your favorite searches!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initFavorites(context);
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