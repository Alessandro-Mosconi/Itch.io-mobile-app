import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool showSaveButton;
  final int filterCount;
  final bool isBookmarked;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final VoidCallback onFilter;
  final VoidCallback onSaveSearch;

  const SearchBar({super.key, 
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
      padding: const EdgeInsets.all(8.0),
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
                        icon: const Icon(Icons.search),
                        onPressed: onSearch,
                      ),
                    ),
                    Visibility(
                      visible: !showSaveButton,
                      child: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onClear,
                      ),
                    ),
                    Visibility(
                      visible: showSaveButton,
                      child: IconButton(
                        icon: badges.Badge(
                          showBadge: filterCount > 0,
                          badgeContent: Text('$filterCount', style: const TextStyle(color: Colors.white)),
                          badgeStyle: const badges.BadgeStyle(),
                          badgeAnimation: const badges.BadgeAnimation.slide(),
                          child: const Icon(Icons.filter_list),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
