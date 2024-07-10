import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itchio/models/filter.dart';
import 'package:itchio/models/item_type.dart';
import 'package:itchio/providers/item_type_provider.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/option.dart';
import '../providers/filter_provider.dart';
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

  const SearchPage({super.key, this.initialTab, this.initialFilters});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final Logger logger = Logger(printer: PrettyPrinter());
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> searchResults;
  late Future<Map<String, dynamic>> tabFilteredResults;
  bool _searchPerformed = false;
  late ItemType currentTab;
  int _filterCount = 0;
  List<Filter> _selectedFilters = [];
  late TabController _tabController;
  List<ItemType> _tabs = [];
  bool _showSaveButton = true;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      searchResults = Future.value({"games": [], "users": []});
      tabFilteredResults = Future.value({"items": [], "title": ""});
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final filterProvider = Provider.of<FilterProvider>(context, listen: false);
        final itemType = Provider.of<ItemTypeProvider>(context, listen: false);
        Future.wait([itemType.fetchTabs(), filterProvider.fetchFilters()]).then(
          (List<dynamic> results) {
            _tabs = results[0] as List<ItemType>;
            currentTab = _tabs.first;
            _tabController = TabController(length: _tabs.length, vsync: this);
            _tabController.addListener(() async {
              setState(() {
                currentTab = _tabs[_tabController.index];
                _changeTab();
              });
            });
            _selectedFilters = results[1] as List<Filter>;
            _initializeTabAndFilters();
            _initializeSearchResults();
          },
        );
      });
    } catch (e) {
      logger.e('Failed to initialize page: $e');
    }
  }

  void _initializeTabAndFilters() async {
    if (widget.initialTab != null) {
      final index = _tabs.indexWhere((tab) => tab.name == widget.initialTab);
      if (index != -1) {
        currentTab = _tabs[index];
        _tabController.index = index;
      }
    }

    if (widget.initialFilters != null) {
      _selectedFilters = _toListOfFilters(_selectedFilters, widget.initialFilters!);
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


  List<Filter> _toListOfFilters(List<Filter> filters, String searchString) {
    final searchItems = searchString.split('/').where((item) => item.isNotEmpty).toList();

    return filters.map((f) {
      f.options = f.options.map((o) {
        o.isSelected = searchItems.contains(o.name);
        return o;
      }).toList();
      return f;
    }).toList();
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

  Future<Map<String, dynamic>> _fetchTabResults(ItemType currentTab, List<Filter> filters) async {
    _searchController.text = '';
    final concatenatedFilters = getSelectedOptions(filters).isNotEmpty
        ? '/${getSelectedOptions(filters).map((option) => option.name).join('/')}'
        : '';

    final currentTabName = currentTab.name ?? 'games';

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

  Future<void> _showFilterPopup(BuildContext context, List<Filter> existingFilters) async {
    final newSelectedFilters = existingFilters.map((f) => Filter(f.toJson())).toList();

    showDialog(
      context: context,
      builder: (context) => FilterPopup(
        selectedFilters: newSelectedFilters
      ),
    ).then((result) {
      if(result!= null){
        setState(() {
          _selectedFilters = result;
          _filterCount = getSelectedOptions(_selectedFilters).length;
          _changeTab();
        });
      }

    });
  }

  List<Option> getSelectedOptions(List<Filter> filters) {
    return filters
        .expand((filter) => filter.options)
        .where((option) => option.isSelected)
        .toList();
  }

  void _performSearch() {
    setState(() {
      _searchPerformed = true;
      searchResults = _fetchSearchResults(_searchController.text);
    });
  }

  Future<void> _changeTab() async {
    final concatenatedFilters = getSelectedOptions(_selectedFilters).isNotEmpty
        ? '/${getSelectedOptions(_selectedFilters).map((option) => option.name).join('/')}'
        : '';

    final currentTabName = currentTab.name ?? 'games';

    bool providerBookmarkSaved = context.read<SearchBookmarkProvider>().isSearchBookmarked(currentTabName, concatenatedFilters);

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
    final tab = currentTab.name ?? 'games';
    final concatenatedFilters = getSelectedOptions(_selectedFilters).isNotEmpty
        ? '/${getSelectedOptions(_selectedFilters).map((option) => option.name).join('/')}'
        : '';

    bool providerBookmarkSaved = context.read<SearchBookmarkProvider>().isSearchBookmarked(tab, concatenatedFilters);

    setState(() {
      isBookmarked = !providerBookmarkSaved;
    });

    if(!providerBookmarkSaved) {
      await context.read<SearchBookmarkProvider>().addSearchBookmark(tab, concatenatedFilters);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search saved successfully')),
      );
    } else {
      await context.read<SearchBookmarkProvider>().removeSearchBookmark(tab, concatenatedFilters);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search removed successfully')),
      );
    }

  }

  Widget _buildTabsPage() {
    if (_tabs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.e('FutureBuilder Error: ${snapshot.error}');
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final games = (data['games'] as List).map((game) => Game(game)).toList();
          final users = (data['users'] as List).map((user) => User(user)).toList();

          return ResponsiveGridList(games: games, isSearch: true);
        } else {
          return const Center(child: Text("No results found"));
        }
      },
    );
  }

  Widget _buildTabPage() {
    return FutureBuilder<Map<String, dynamic>>(
      future: tabFilteredResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.e('FutureBuilder Error: ${snapshot.error}');
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final items = (data['items'] as List).map((game) => Game(game)).toList();
          final title = data['title'].replaceAll(" - itch.io", "") as String;

          return Column(
            children: [
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: ResponsiveGridList(games: items),
              ),
            ],
          );
        } else {
          return const Center(child: Text("No results found"));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
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
