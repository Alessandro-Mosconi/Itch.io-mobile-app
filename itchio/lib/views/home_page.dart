import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_searches_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/saved_search_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedSearchesProvider>(context, listen: false).fetchSavedSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Consumer<SavedSearchesProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.refreshSavedSearches,
            child: SavedSearchList(savedSearches: provider.savedSearches),
          );
        },
      ),
    );
  }
}