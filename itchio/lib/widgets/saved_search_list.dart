import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
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

class _SavedSearchListState extends State<SavedSearchList> with TickerProviderStateMixin {

  late AnimationController _lottieController;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _lottieController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.savedSearches.isEmpty
        ? ListView(
      children: [
        _buildEmptyStateWidget('No saved searches yet', 'Start exploring and save your favorite games!')
      ],
    )
        :ReorderableListView.builder(
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