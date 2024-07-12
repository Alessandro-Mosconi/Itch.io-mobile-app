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
import '../providers/search_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/responsive_grid_list_game.dart';
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
  late ItemType currentTab;
  int _filterCount = 0;
  List<Filter> _selectedFilters = [];
  late TabController _tabController;
  List<ItemType> _tabs = [];
  bool _searchPerformed = false;
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
        final searchBookMarkProvider = Provider.of<SearchBookmarkProvider>(context, listen: false);
        Future.wait([itemType.fetchTabs(), filterProvider.fetchFilters()]).then(
          (List<dynamic> results) {
            setState(() {
              _tabs = results[0] as List<ItemType>;
              _selectedFilters = results[1] as List<Filter>;
              currentTab = _tabs.first;
              _tabController = TabController(length: _tabs.length, vsync: this);
              _tabController.addListener(() async {
                setState(() {
                  isBookmarked = searchBookMarkProvider.isSearchBookmarked(currentTab.name!, getFilterString(_selectedFilters));
                  currentTab = _tabs[_tabController.index];
                });
              });
              _initializeTabAndFilters();
              _initializeSearchResults();
              isBookmarked = searchBookMarkProvider.isSearchBookmarked(currentTab.name!, getFilterString(_selectedFilters));
            });
          },
        );
      });
    } catch (e) {
      logger.e('Failed to initialize page: $e');
    }
  }

  void _initializeTabAndFilters() {
    if (widget.initialTab != null) {
      final index = _tabs.indexWhere((tab) => tab.name == widget.initialTab);
      if (index != -1) {
        currentTab = _tabs[index];
        _tabController.index = index;
      } else {
        logger.i('qua');
        currentTab = _tabs.first;
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

  Future<void> _showFilterPopup(BuildContext context, List<Filter> existingFilters) async {
    final newSelectedFilters = existingFilters.map((f) => Filter(f.toJson())).toList();

    final searchBookMarkProvider = Provider.of<SearchBookmarkProvider>(context, listen: false);
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
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
          isBookmarked = searchBookMarkProvider.isSearchBookmarked(currentTab.name!, getFilterString(_selectedFilters));
          searchBookMarkProvider.reloadBookMarkProvider();
          searchProvider.reloadSearchProvider();
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

  String getFilterString(List<Filter> filters) {
    return getSelectedOptions(_selectedFilters).isNotEmpty
        ? '/${getSelectedOptions(_selectedFilters).map((option) => option.name).join('/')}'
        : '';
  }

  void _performSearch() {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    setState(() {
      _searchPerformed = true;
      searchResults = searchProvider.fetchSearchResults(_searchController.text);
    });
  }

  Widget _buildSearchBar() {

    return custom.SearchBar(
      searchController: _searchController,
      showSaveButton: !_searchPerformed,
      filterCount: _filterCount,
      isBookmarked: isBookmarked,
      onSearch: _performSearch,
      onClear: () {
        _searchController.text = '';
        setState(() => _searchPerformed = false);
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
              children: _tabs.map((tab) => _buildTabPage(tab, _selectedFilters)).toList(),
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

          return ResponsiveGridListGame(games: games, isSearch: true);
        } else {
          return const Center(child: Text("No results found"));
        }
      },
    );
  }

  Widget _buildTabPage(ItemType tab, List<Filter> filters) {
    final searchFilterProvider = Provider.of<SearchProvider>(context, listen: false);

    Future<void> _reloadData() async {
      await searchFilterProvider.reloadSearchProvider();
      setState(() {
        searchFilterProvider.fetchTabResults(tab, filters);
      });
    }

    return RefreshIndicator(
      onRefresh: _reloadData,
      child: FutureBuilder<Map<String, dynamic>>(
        future: searchFilterProvider.fetchTabResults(tab, filters),
        builder: (context, snapshot) {
          Widget content;
          if (snapshot.hasError) {
            logger.e('FutureBuilder Error: ${snapshot.error}');
            content = Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!['items'].isNotEmpty) {
            final data = snapshot.data!;
            final items = (data['items'] as List).map((game) => Game(game)).toList();
            final title = data['title'].replaceAll(" - itch.io", "") as String;
            content = _buildContent(items, title);
          } else {
            content = const Center(child: Text("No results found"));
          }

          return Stack(
            children: [
              content,
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.active)
                  Center(
                    child: CircularProgressIndicator(),
                  )
            ],
          );
        },
      ),
    );
  }
  Widget _buildContent(List<Game> items, String title) {
    return Column(
      children: [
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: ResponsiveGridListGame(games: items),
        ),
      ],
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
