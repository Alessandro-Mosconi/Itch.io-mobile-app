import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/saved_searches_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/saved_search_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedSearchesProvider>(context, listen: false)
          .fetchSavedSearch()
          .then((_) => setState(() => isLoading = false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<SavedSearchesProvider>(
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