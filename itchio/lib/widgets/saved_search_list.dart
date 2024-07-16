import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../models/saved_search.dart';
import '../providers/saved_searches_provider.dart';
import 'carousel_card.dart';
final Logger logger = Logger(printer: PrettyPrinter());

class SavedSearchList extends StatefulWidget {
  final List<SavedSearch> savedSearches;

  const SavedSearchList({
    Key? key,
    required this.savedSearches,
  }) : super(key: key);

  @override
  _SavedSearchListState createState() => _SavedSearchListState();
}

class _SavedSearchListState extends State<SavedSearchList> {
  bool _isReordering = false;

  @override
  Widget build(BuildContext context) {
    logger.i(widget.savedSearches.map((s)=>s.filters).toList());
    return ReorderableListView.builder(
      itemCount: widget.savedSearches.length,
      itemBuilder: (context, index) {
        SavedSearch search = widget.savedSearches[index];
        return ShakingWidget(
          key: ValueKey(search.getKey()),
          isShaking: _isReordering,
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
      },
      onReorderStart: (index) {
        setState(() {
          _isReordering = true;
        });
      },
      onReorderEnd: (index) {
        setState(() {
          _isReordering = false;
        });
      },
      onReorder: (oldIndex, newIndex) {
        Provider.of<SavedSearchesProvider>(context, listen: false)
            .reorderSavedSearches(oldIndex, newIndex);
      },
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
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
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