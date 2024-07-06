import 'package:flutter/material.dart';
import '../models/saved_search.dart';
import 'carousel_card.dart';

class SavedSearchList extends StatelessWidget {
  final List<SavedSearch> savedSearches;

  const SavedSearchList({super.key, required this.savedSearches});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: savedSearches.length,
      itemBuilder: (context, index) {
        SavedSearch search = savedSearches[index];
        return CarouselCard(
          title: search.type ?? '',
          subtitle: search.filters ?? '',
          items: search.items ?? [],
          notify: search.notify ?? false,
          onUpdateSavedSearches: (bool hasChanges) {
            if (hasChanges) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Saved searches updated"),
              ));
            }
          },
        );
      },
    );
  }
}
