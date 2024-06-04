import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges; // Alias this import

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool showSaveButton;
  final int filterCount;
  final bool isBookmarked;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final VoidCallback onFilter;
  final VoidCallback onSaveSearch;

  SearchBar({
    required this.searchController,
    required this.showSaveButton,
    required this.filterCount,
    required this.isBookmarked,
    required this.onSearch,
    required this.onClear,
    required this.onFilter,
    required this.onSaveSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for games or users...',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: showSaveButton,
                      child: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: onSearch,
                      ),
                    ),
                    Visibility(
                      visible: !showSaveButton,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: onClear,
                      ),
                    ),
                    Visibility(
                      visible: showSaveButton,
                      child: IconButton(
                        icon: badges.Badge(
                          showBadge: filterCount > 0,
                          badgeContent: Text('$filterCount', style: TextStyle(color: Colors.white)),
                          badgeStyle: badges.BadgeStyle(),
                          badgeAnimation: badges.BadgeAnimation.slide(),
                          child: Icon(Icons.filter_list),
                        ),
                        onPressed: onFilter,
                      ),
                    ),
                    Visibility(
                      visible: showSaveButton,
                      child: IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        onPressed: onSaveSearch,
                      ),
                    ),
                  ],
                ),
              ),
              onSubmitted: (value) {
                onSearch();
                // set the state to not show the save button once a search is performed
              },
            ),
          ),
        ],
      ),
    );
  }
}
