import 'dart:ffi';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import '../customIcons/custom_icon_icons.dart';
import '../helperClasses/Game.dart';
import '../helperClasses/User.dart';
import '../widgets/game_tile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_database/firebase_database.dart';

class SearchPage extends StatefulWidget {
  String? initialTab;
  String? initialFilters;

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
  late List<Map<String, String>> _tabs = [];
  bool _showSaveButton = true;

  @override
  void initState() {
    super.initState();
    Future.wait([
      fetchFilters(),
      fetchTabs(),
    ]).then((List<dynamic> results) {
      Map<String, List<Map<String, String>>> filtersData = results[0] as Map<String, List<Map<String, String>>>;

      logger.i(widget.initialTab);
      if (widget.initialTab != null) {
        final index = _tabs.indexWhere((tab) => tab['name'] == widget.initialTab!);

        if (index != -1) {
          currentTab = _tabs[index];
          _tabController.index = index;
        }
      }

      if (widget.initialFilters != null) {
        setState(() {
          _selectedFilters = filterMap(filtersData, widget.initialFilters!);
          int count = (widget.initialFilters!.split('/').length - 1);
          _filterCount = count;
        });
      }

      searchResults = Future.value({"games": [], "users": []});
      tabFilteredResults = Future.value({"items": [], "title": ""});
      _changeTab();
    });
  }
  Map<String, Set<String>> filterMap(
      Map<String, List<Map<String, String>>> data, String searchString) {

    List<String> searchItems = searchString.split('/').where((item) => item.isNotEmpty).toList();
    Map<String, Set<String>> filteredData = {};

    data.forEach((key, value) {
      Set<String> filteredList = {};
      for (var item in value) {
        String itemName = item['name']!;
        logger.i(itemName);
        if (searchItems.contains(itemName)) {
          filteredList.add(itemName);
        }
      }
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

  Future<Map<String, dynamic>> fetchTabResults(Map<String, String> currentTab, Map<String, Set<String>> filters) async {
    _searchController.text = '';

    var concatenatedFilters = '';

    if(filters.entries.isNotEmpty && filters.entries.every((e) => e.value.isNotEmpty)){
      concatenatedFilters = '/${filters.entries.expand((entry) => entry.value).join('/')}';
    }

    final currentTabName = (currentTab['name'] ?? 'games');
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

  Future<void> fetchTabs() async {
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

          _tabController = TabController(length: _tabs.length, vsync: this)
            ..addListener(() {
              if (_tabController.indexIsChanging) {
                setState(() {
                  currentTab = _tabs[_tabController.index];
                  _changeTab();
                });
              }
            });
        });
      } else {
        logger.i('Unexpected data type: ${data.runtimeType}');
      }
    } else {
      logger.i('No data available.');
    }
  }

  Future<Map<String, List<Map<String, String>>>> fetchFilters() async {
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

  Future<void> uploadSavedSearchToDb() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    var concatenatedFilters = '';
    var tab = currentTab['name'] ?? 'games';
    if(_selectedFilters.entries.isNotEmpty && _selectedFilters.entries.every((e) => e.value.isNotEmpty)){
      concatenatedFilters = '/${_selectedFilters.entries.expand((entry) => entry.value).join('/')}';
    }

    String key = sha256.convert(utf8.encode(tab + concatenatedFilters)).toString();

    if(widget.initialTab != null){
      String oldKey = sha256.convert(utf8.encode(widget.initialTab! + (widget.initialFilters ?? ''))).toString();
      final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$oldKey');
      await dbRef.remove();
      widget.initialTab = tab;
      widget.initialFilters = concatenatedFilters;

    }

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.update(
        {
          "filters" : concatenatedFilters,
          "type": currentTab['name'] ?? 'games'
        }
    );

    prefs.remove("saved_searches");
  }

  void _performSearch() {
    setState(() {
      //_filterCount = 0;
      //_selectedFilters = {};
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

  Future<void> _showFilterPopup(Map<String, Set<String>> existingFilters) async {
    Map<String, Set<String>> newSelectedFilters = Map.from(existingFilters);

    List<Widget> filterRows = await _buildFilterRows(newSelectedFilters);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: filterRows
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
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<List<Widget>> _buildFilterRows(Map<String, Set<String>> selectedFilters) async {
    List<Widget> filterRows = [];
    Map<String, List<Map<String, String>>> filtersData = (await fetchFilters()) as Map<String, List<Map<String, String>>>;

    filtersData.forEach((label, options) {
      filterRows.add(
        FilterRowWidget(
          label: label,
          options: options.toList(),
          selectedFilters: selectedFilters,
          onFiltersChanged: (filters) => selectedFilters = filters,
        ),
      );
    });

    return filterRows;
  }

  void _saveSearch() {
    logger.i(_selectedFilters);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bookmark'),
        content: widget.initialTab == null ?
          Text('You are going to save this research in home page')
        : Text('You are going to edit this research in home page'),
        actions: <Widget>[
          TextButton(
              child: Text('Confirm'),
              onPressed: () =>
              {
                uploadSavedSearchToDb(),
                Navigator.of(context).pop()
              }
          ),
          TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
                    Visibility(
                      visible: _showSaveButton && _filterCount == 0,
                      child: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: (){
                          _performSearch();
                          setState(() {
                            _showSaveButton = false;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: !_showSaveButton,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: (){
                          _searchController.text = '';
                          _performSearch();
                          setState(() {
                            _showSaveButton = true;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: _showSaveButton,
                      child: IconButton(
                        icon: badges.Badge(
                          showBadge: _filterCount > 0,
                          badgeContent: Text('$_filterCount', style: TextStyle(color: Colors.white)),
                          badgeStyle: badges.BadgeStyle(),
                          badgeAnimation: badges.BadgeAnimation.slide(),
                          child: Icon(Icons.filter_list),
                        ),
                        onPressed: () => _showFilterPopup(_selectedFilters),
                      ),
                    ),
                    Visibility(
                      visible: _showSaveButton,
                      child: IconButton(
                        icon: Icon(Icons.bookmark),
                        onPressed: _saveSearch,
                      ),
                    ),
                  ],
                ),
              ),
              onSubmitted:  (value) {
                _performSearch();
                setState(() {
                  _showSaveButton = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSearchActions() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
    if (_tabs.isEmpty) {
      return [
        const Center(child: CircularProgressIndicator()),
      ];
    } else {
      return [
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
      ];
    }
  }

}

class FilterRowWidget extends StatefulWidget {
  final String label;
  final List<Map<String, String>> options;
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
              final isSelected = widget.selectedFilters.entries.any((entry) => entry.value.contains(option['name']));
              return Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(option['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        widget.selectedFilters[widget.label] ??= Set();
                        widget.selectedFilters[widget.label]!.add(option['name']!);
                      } else {
                        widget.selectedFilters[widget.label]?.remove(option['name']);
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

