import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'custom_app_bar.dart';
import 'customIcons/custom_icon_icons.dart';
import 'helperClasses/Game.dart';
import 'helperClasses/User.dart';
import 'package:badges/badges.dart' as badges;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> searchResults;
  bool _searchPerformed = false;

  int _filterCount = 0;
  Map<String, Set<String>> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    // Initialize with an empty Future
    searchResults = Future.value({"games": [], "users": []});
  }

  Future<Map<String, dynamic>> fetchSearchResults(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/search?search=$query'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load search results, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load search results');
      }
    } catch (error) {
      print('Error fetching search results: $error');
      throw Exception('Failed to load search results');
    }
  }

  void _performSearch() {
    setState(() {
      _searchPerformed = true;
      searchResults = fetchSearchResults(_searchController.text);
    });
  }

  void _showFilterPopup(Map<String, Set<String>> existingFilters) {
    Map<String, Set<String>> newSelectedFilters = Map.from(existingFilters);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterRowWidget(
                  label: 'Category',
                  options: ['Action', 'Adventure', 'Puzzle'],
                  selectedFilters: newSelectedFilters,
                  onFiltersChanged: (filters) {
                    logger.i(filters);
                    newSelectedFilters = filters;
                  },
                ),
                FilterRowWidget(
                  label: 'Price',
                  options: ['Free', 'Paid'],
                  selectedFilters: newSelectedFilters,
                  onFiltersChanged: (filters) {
                    newSelectedFilters = filters;
                  },
                ),
                FilterRowWidget(
                  label: 'Platform',
                  options: ['Windows', 'MacOS', 'Linux', 'Android'],
                  selectedFilters: newSelectedFilters,
                  onFiltersChanged: (filters) {
                    newSelectedFilters = filters;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  _selectedFilters = newSelectedFilters;
                  _filterCount = _selectedFilters.values.fold(0, (prev, elem) => prev + elem.length);
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for games or users...',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: _performSearch,
                          ),

                          IconButton(
                            icon: _filterCount > 0
                                ? badges.Badge(
                              showBadge: true,
                              badgeContent: Text(
                                '$_filterCount',
                                style: TextStyle(color: Colors.white),
                              ),
                              badgeStyle: badges.BadgeStyle(),
                              badgeAnimation: badges.BadgeAnimation.slide(),
                              child: Icon(Icons.filter_list),
                            )
                                : Icon(Icons.filter_list),
                            onPressed: () => {
                              _showFilterPopup(_selectedFilters),
                            },
                          ),

                        ],
                      ),
                    ),
                    onSubmitted: (value) => _performSearch(),
                  ),
                ),
              ],
            ),
          ),
          if (!_searchPerformed)
            Center(child: Text('Enter a search query to begin')),
          if (_searchPerformed)
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('FutureBuilder Error: ${snapshot.error}');
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    var data = snapshot.data!;
                    List<Game> games = (data['games'] as List).map((game) => Game(game)).toList();
                    List<User> users = (data['users'] as List).map((user) => User(user)).toList();

                    return ListView(
                      children: [
                        if (games.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...games.map((game) => GameTile(game: game)).toList(),
                        ],
                        if (users.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...users.map((user) => UserTile(user: user)).toList(),
                        ],
                      ],
                    );
                  } else {
                    return Center(child: Text("No results found"));
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  final Game game;

  const GameTile({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.network(
                  game.imageurl ?? "https://via.placeholder.com/50", // Default image URL
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            game.title ?? "Default Title", // Default title
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          game.min_price == 0
                              ? Text(
                            "Free",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          )
                              : Text(
                            "${(game.min_price != null ? game.min_price! / 100 : 0).toStringAsFixed(2)} €", // Check for null
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(game.description ?? "No description", style: TextStyle(fontSize: 14)), // Default description
                      SizedBox(height: 8),
                      Row(
                        children: [
                          if (game.p_windows ?? false) Icon(CustomIcon.windows, size: 16, color: Colors.grey),
                          if (game.p_osx ?? false) Icon(Icons.apple, size: 24, color: Colors.grey),
                          if (game.p_linux ?? false) Icon(CustomIcon.linux, size: 16, color: Colors.grey),
                          if (game.p_android ?? false) Icon(Icons.android, size: 24, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              "$count",
              style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
    margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Image.network(
              user.avatar ?? "https://via.placeholder.com/50", // Default image URL
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName ?? "Default Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Default name
                Text('${user.numberOfProjects ?? 0} Projects', style: TextStyle(fontSize: 14)), // Default projects count
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class FilterRowWidget extends StatefulWidget {
  final String label;
  final List<String> options;
  final Map<String, Set<String>> selectedFilters;
  final void Function(Map<String, Set<String>>) onFiltersChanged;

  FilterRowWidget({required this.label, required this.options, required this.selectedFilters, required this.onFiltersChanged});

  @override
  _FilterRowWidgetState createState() => _FilterRowWidgetState();
}

class _FilterRowWidgetState extends State<FilterRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.options.map((option) {
              bool isSelected = widget.selectedFilters.entries.any((entry) => entry.value.contains(option));
              return Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        widget.selectedFilters[widget.label] ??= Set();
                        widget.selectedFilters[widget.label]!.add(option);
                      } else {
                        widget.selectedFilters[widget.label]?.remove(option);
                      }
                    });
                  },
                  selectedColor: isSelected ? Colors.blue : null,
                  backgroundColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}