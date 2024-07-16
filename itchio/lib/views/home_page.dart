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
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          Consumer<SavedSearchesProvider>(
            builder: (context, provider, child) {
              if (provider.savedSearches.length >= 2) {
                return IconButton(
                  icon: Icon(_isEditMode ? Icons.done : Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                    });
                  },
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<SavedSearchesProvider>(
        builder: (context, provider, child) {
          return SavedSearchList(
            savedSearches: provider.savedSearches,
            isEditMode: _isEditMode,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedSearchesProvider>(context, listen: false).fetchSavedSearch();
    });
  }
}