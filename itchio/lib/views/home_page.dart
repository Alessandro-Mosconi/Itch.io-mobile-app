import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/saved_searches_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/saved_search_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _lottieController.repeat(reverse: true);
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
            child:
            provider.savedSearches.isEmpty?
            ListView(
              children: [
                _buildEmptyStateWidget('No saved searches yet', 'Start exploring and save your favorite games!')
              ],
            )
          : SavedSearchList(savedSearches: provider.savedSearches),
          );
        },
      ),
    );
  }


  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Widget _buildEmptyStateWidget(String title, String message) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/81ee35fc-7d8f-4356-81fc-801e078d7014/jETcdSHcKj.json',
              controller: _lottieController,
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}