import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'custom_app_bar.dart';
import 'customIcons/custom_icon_icons.dart';
import 'helperClasses/Game.dart';
import 'helperClasses/User.dart';
import 'game_tile.dart'; // Import the external GameTile widget
import 'package:badges/badges.dart' as badges;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final Logger logger = Logger(printer: PrettyPrinter());
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> searchResults;
  late Future<Map<String, dynamic>> tabFilteredResults;
  bool _searchPerformed = false;
  bool _showSearchBar = true;
  String currentTab = "games";
  int _filterCount = 0;
  Map<String, Set<String>> _selectedFilters = {};
  late TabController _tabController;
  final List<String> _tabs = ['games', 'misc'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          setState(() {
            currentTab = _tabs[_tabController.index];
            _changeTab();
          });
        }
      });
    searchResults = Future.value({"games": [], "users": []});
    tabFilteredResults = Future.value({"items": [], "title": ""});
    _changeTab();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchSearchResults(String query) async {
    final response = await http.get(
      Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/search?search=$query'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      logger.e('Failed to load search results, status code: ${response.statusCode}');
      throw Exception('Failed to load search results');
    }
  }

  Future<Map<String, dynamic>> fetchTabResults(String currentTab, Map<String, Set<String>> filters) async {
    final concatenatedFilters = filters.entries
        .expand((entry) => entry.value)
        .join(',');

    final response = await http.post(
      Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/item_list'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'filters': concatenatedFilters, 'type': currentTab}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      logger.e('Failed to load tab results, status code: ${response.statusCode}');
      throw Exception('Failed to load tab results');
    }
  }

  void _performSearch() {
    setState(() {
      _searchPerformed = true;
      searchResults = fetchSearchResults(_searchController.text);
    });
  }

  void _changeTab() {
    setState(() {
      _searchPerformed = true;
      tabFilteredResults = fetchTabResults(currentTab, _selectedFilters);
    });
  }

  void _showFilterPopup(Map<String, Set<String>> existingFilters) {
    Map<String, Set<String>> newSelectedFilters = Map.from(existingFilters);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterRowWidget(
                label: 'Category',
                options: ['/genre-action', 'genre-adventure'],
                selectedFilters: newSelectedFilters,
                onFiltersChanged: (filters) => newSelectedFilters = filters,
              ),
              FilterRowWidget(
                label: 'Price',
                options: ['/free', '/5-dollars-or-less'],
                selectedFilters: newSelectedFilters,
                onFiltersChanged: (filters) => newSelectedFilters = filters,
              ),
              FilterRowWidget(
                label: 'Platform',
                options: ['/platform_windows', '/platform_osx', '/platform_linux', '/platform_android'],
                selectedFilters: newSelectedFilters,
                onFiltersChanged: (filters) => newSelectedFilters = filters,
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
                _showSearchBar = _filterCount == 0;
              });
              _changeTab();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Close'),
            onPressed: () {
              setState(() => _showSearchBar = true);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _saveSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bookmark'),
        content: Text('Search saved in the home'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          if (_showSearchBar)
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
                              icon: badges.Badge(
                                showBadge: _filterCount > 0,
                                badgeContent: Text('$_filterCount', style: TextStyle(color: Colors.white)),
                                badgeStyle: badges.BadgeStyle(),
                                badgeAnimation: badges.BadgeAnimation.slide(),
                                child: Icon(Icons.filter_list),
                              ),
                              onPressed: () => _showFilterPopup(_selectedFilters),
                            ),
                            IconButton(
                              icon: Icon(Icons.bookmark),
                              onPressed: _saveSearch,
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
          if (_searchController.text.isEmpty)
            ..._buildTabsPage(),
          if (_searchPerformed && _searchController.text.isNotEmpty)
            Expanded(
              child: _buildSearchPage(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchPage() {
    return FutureBuilder<Map<String, dynamic>>(
      future: searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.e('FutureBuilder Error: ${snapshot.error}');
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final games = (data['games'] as List).map((game) => Game(game)).toList();
          final users = (data['users'] as List).map((user) => User(user)).toList();

          return ListView(
            children: [
              if (games.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ...games.map((game) => GameTile(game: game)).toList(),
            ],
          );
        } else {
          return Center(child: Text("No results found"));
        }
      },
    );
  }

  Widget _buildTabPage() {
    return FutureBuilder<Map<String, dynamic>>(
        future: tabFilteredResults,
        builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        logger.e('FutureBuilder Error: ${snapshot.error}');
        return Center(child: Text("Error: ${snapshot.error}"));
      } else if (snapshot.hasData) {
        final data = snapshot.data!;
        final items = (data['items'] as List).map((game) => Game(game)).toList();
        final title = data['title'] as String;

        return ListView(
          children: [
            if (items.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ...items.map((game) => GameTile(game: game)).toList(),
          ],
        );
      } else {
        return Center(child: Text("No results found"));
      }
        },
    );
  }

  List<Widget> _buildTabsPage() {
    return [
      TabBar(
        controller: _tabController,
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) => _buildTabPage()).toList(),
        ),
      ),
    ];
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
              final isSelected = widget.selectedFilters.entries.any((entry) => entry.value.contains(option));
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
                      widget.onFiltersChanged(widget.selectedFilters);
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
