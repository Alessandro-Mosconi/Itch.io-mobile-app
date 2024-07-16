import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_search.dart';
import '../providers/saved_searches_provider.dart';
import 'carousel_card.dart';

class SavedSearchList extends StatelessWidget {
  final List<SavedSearch> savedSearches;
  final bool isEditMode;

  const SavedSearchList({
    Key? key,
    required this.savedSearches,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: savedSearches.length,
      itemBuilder: (context, index) {
        SavedSearch search = savedSearches[index];
        return _buildCarouselCard(context, search, index);
      },
      onReorder: (oldIndex, newIndex) {
        if (isEditMode) {
          Provider.of<SavedSearchesProvider>(context, listen: false)
              .reorderSavedSearches(oldIndex, newIndex);
        }
      },
    );
  }

  Widget _buildCarouselCard(BuildContext context, SavedSearch search, int index) {
    return ShakingWidget(
      key: ValueKey(search.getKey()),
      isShaking: isEditMode,
      child: CarouselCard(
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
      ),
    );
  }
}

class ShakingWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;

  const ShakingWidget({Key? key, required this.child, this.isShaking = false}) : super(key: key);

  @override
  _ShakingWidgetState createState() => _ShakingWidgetState();
}

class _ShakingWidgetState extends State<ShakingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -3, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isShaking ? Offset(_animation.value, 0) : Offset.zero,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}