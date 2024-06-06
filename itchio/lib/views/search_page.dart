import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/responsive_grid_list.dart';
import '../models/game.dart';
import '../models/User.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/filter_popup.dart';
import '../providers/search_bookmark_provider.dart';

class SearchPage extends StatefulWidget {
  final String? initialTab;
  final String? initialFilters;

  SearchPage({this.initialTab, this.initialFilters});

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
  Map<String, String> currentTab = {};
  int _filterCount = 0;
  Map<String, Set<String>> _selectedFilters = {};
  late TabController _tabController;
  List<Map<String, String>> _tabs = [];
  bool _showSaveButton = true;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      await Future.wait([_fetchFilters(), _fetchTabs()]);
      await _initializeTabAndFilters();
      _initializeSearchResults();
    } catch (e) {
      logger.e('Failed to initialize page: $e');
    }
  }

  Future<void> _initializeTabAndFilters() async {
    if (widget.initialTab != null) {
      final index = _tabs.indexWhere((tab) => tab['name'] == widget.initialTab);
      if (index != -1) {
        currentTab = _tabs[index];
        _tabController.index = index;
      }
    }

    if (widget.initialFilters != null) {
      final filtersData = await _fetchFilters();
      _selectedFilters = _filterMap(filtersData, widget.initialFilters!);
      _filterCount = widget.initialFilters!.split('/').length - 1;
    }
  }


  void _initializeSearchResults() {
    setState(() {
      searchResults = Future.value({"games": [], "users": []});
      tabFilteredResults = Future.value({"items": [], "title": ""});
      _changeTab();
    });
  }

  Future<Map<String, List<Map<String, String>>>> _fetchFilters() async {
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/items/filters');
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic data = snapshot.value;
      Map<String, List<Map<String, String>>> resultMap = {};

      data.forEach((key, value) {
        if (key is String) {
          if (value is List) {
            List<Map<String, String>> listValue = [];
            for (var item in value) {
              if (item is Map) {
                Map<String, String> stringMap = {};

                item.forEach((key, value) {
                  if (key is String && value is String) {
                    stringMap[key] = value;
                  }
                });

                listValue.add(stringMap);
              }
            }

            resultMap[key] = listValue;
          }
        }
      });
      return resultMap;
    } else {
      logger.i('No data available.');
      return {};
    }
  }

  Future<void> _fetchTabs() async {
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/items/item_types');
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic data = snapshot.value;
      if (data is List<dynamic>) {
        setState(() {
          _tabs = data.map((item) {
            if (item is Map<Object?, Object?>) {
              final Map<String, String> convertedMap = {};
              item.forEach((key, value) {
                if (key != null && value != null) {
                  convertedMap[key.toString()] = value.toString();
                }
              });
              return convertedMap;
            } else {
              return <String, String>{};
            }
          }).toList();

          _tabController = TabController(length: _tabs.length, vsync: this);
          _tabController.addListener(() async {
              setState(() {
                currentTab = _tabs[_tabController.index];
                _changeTab();
              });
            });
        });
      } else {
        logger.i('Unexpected data type: ${data.runtimeType}');
      }
    } else {
      logger.i('No data available.');
    }
  }

  Map<String, Set<String>> _filterMap(Map<String, List<Map<String, String>>> data, String searchString) {
    final searchItems = searchString.split('/').where((item) => item.isNotEmpty).toList();
    final filteredData = <String, Set<String>>{};

    data.forEach((key, value) {
      final filteredList = value
          .where((item) => searchItems.contains(item['name']))
          .map((item) => item['name']!)
          .toSet();
      if (filteredList.isNotEmpty) {
        filteredData[key] = filteredList;
      }
    });

    return filteredData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchSearchResults(String query) async {
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

  Future<Map<String, dynamic>> _fetchTabResults(Map<String, String> currentTab, Map<String, Set<String>> filters) async {
    _searchController.text = '';
    final concatenatedFilters = filters.entries.isNotEmpty
        ? '/${filters.entries.expand((entry) => entry.value).join('/')}'
        : '';

    final currentTabName = currentTab['name'] ?? 'games';

    final response = await http.post(
      Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/item_list'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'filters': concatenatedFilters, 'type': currentTabName}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      logger.e('Type: $currentTabName, Filters: $concatenatedFilters');
      logger.e('Failed to load tab results, status code: ${response.statusCode}');
      throw Exception('Failed to load tab results');
    }
  }

  Future<void> _showFilterPopup(BuildContext context, Map<String, Set<String>> existingFilters) async {
    final newSelectedFilters = Map<String, Set<String>>.from(existingFilters);

    showDialog(
      context: context,
      builder: (context) => FilterPopup(
        selectedFilters: newSelectedFilters,
        onFiltersChanged: (filters) => setState(() {
          _selectedFilters = filters;
          _filterCount = filters.values.fold(0, (prev, elem) => prev + elem.length);
          _showSearchBar = _filterCount == 0;
        }),
        fetchFilters: _fetchFilters(),
      ),
    ).then((_) {
      // After the popup is closed, update the tab
      _changeTab();
    });
  }

  void _performSearch() {
    setState(() {
      _searchPerformed = true;
      searchResults = _fetchSearchResults(_searchController.text);
    });
  }

  Future<void> _changeTab() async {
    final concatenatedFilters = _selectedFilters.entries.isNotEmpty
        ? '/${_selectedFilters.entries.expand((entry) => entry.value).join('/')}'
        : '';

    final currentTabName = currentTab['name'] ?? 'games';

    bool providerBookmarkSaved = await context.read<SearchBookmarkProvider>().isSearchBookmarked(currentTabName, concatenatedFilters);

    setState(() {
      isBookmarked = providerBookmarkSaved;
      tabFilteredResults = _fetchTabResults(currentTab, _selectedFilters);
    });
  }

  Widget _buildSearchBar() {
    return custom.SearchBar(
      searchController: _searchController,
      showSaveButton: _showSaveButton,
      filterCount: _filterCount,
      isBookmarked: isBookmarked,
      onSearch: _performSearch,
      onClear: () {
        _searchController.text = '';
        _changeTab();
        setState(() => _showSaveButton = true);
      },
      onFilter: () => _showFilterPopup(context, _selectedFilters),
      onSaveSearch: () => _saveSearch(),
    );
  }

  Future<void> _saveSearch() async {
    final tab = currentTab['name'] ?? 'games';
    final concatenatedFilters = _selectedFilters.entries.isNotEmpty
        ? '/${_selectedFilters.entries.expand((entry) => entry.value).join('/')}'
        : '';

    bool providerBookmarkSaved = await context.read<SearchBookmarkProvider>().isSearchBookmarked(tab, concatenatedFilters);

    setState(() {
      isBookmarked = !providerBookmarkSaved;
    });

    if(!providerBookmarkSaved) {
      await context.read<SearchBookmarkProvider>().addSearchBookmark(tab, concatenatedFilters);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search saved successfully')),
      );
    } else {
      await context.read<SearchBookmarkProvider>().removeSearchBookmark(tab, concatenatedFilters);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search removed successfully')),
      );
    }

  }

  Widget _buildTabsPage() {
    if (_tabs.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              tabs: _tabs.map((tab) => Tab(text: tab['label'])).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildTabPage()).toList(),
            ),
          ),
        ],
      );
    }
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

          return ResponsiveGridList(games: games, isSearch: true);
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

          return Column(
            children: [
              if (items.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: ResponsiveGridList(games: items),
              ),
            ],
          );
        } else {
          return Center(child: Text("No results found"));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_searchController.text.isEmpty)
            Expanded(child: _buildTabsPage()),
          if (_searchPerformed && _searchController.text.isNotEmpty)
            Expanded(child: _buildSearchPage()),
        ],
      ),
    );
  }
}
