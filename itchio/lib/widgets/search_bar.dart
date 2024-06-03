import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool showSaveButton;
  final int filterCount;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final VoidCallback onFilter;
  final VoidCallback onSaveSearch;

  SearchBar({
    required this.searchController,
    required this.showSaveButton,
    required this.filterCount,
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
                    if (showSaveButton)
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: onSearch,
                      ),
                    if (!showSaveButton)
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: onClear,
                      ),
                    if (showSaveButton)
                      IconButton(
                        icon: badges.Badge(
                          showBadge: filterCount > 0,
                          badgeContent: Text('$filterCount', style: TextStyle(color: Colors.white)),
                          badgeStyle: badges.BadgeStyle(),
                          badgeAnimation: badges.BadgeAnimation.slide(),
                          child: Icon(Icons.filter_list),
                        ),
                        onPressed: onFilter,
                      ),
                    if (showSaveButton && filterCount > 0)
                      IconButton(
                        icon: Icon(Icons.bookmark),
                        onPressed: onSaveSearch,
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
