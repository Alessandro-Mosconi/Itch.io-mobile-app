import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:itchio/providers/saved_searches_provider.dart';
import 'package:itchio/providers/search_bookmark_provider.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../providers/page_provider.dart';
import '../views/game_webview_page.dart';
import '../services/notification_service.dart';
import '../views/search_page.dart';

class CarouselCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Game> items;
  final bool notify;

  const CarouselCard({super.key, 
    required this.title,
    required this.subtitle,
    required this.items,
    required this.notify,
  });

  @override
  _CarouselCardState createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  bool isNotificationEnabled = false;
  late ScrollController _scrollController;
  late Timer _scrollTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    isNotificationEnabled = widget.notify;
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        const delta = 200.0;

        if (currentScroll + delta >= maxScroll) {
          await _scrollController.animateTo(
            0.0,
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
          );
        } else {
          await _scrollController.animateTo(
            currentScroll + delta,
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
          );
        }

        final randomDelay = Duration(seconds: _random.nextInt(5) + 1);
        await Future.delayed(randomDelay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Dismissible(
        key: Key(widget.title),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) => _confirmDismiss(direction, context),
        background: _buildDismissBackground(
          Alignment.centerLeft,
          theme.colorScheme.secondary,
          Icons.search,
        ),
        secondaryBackground: _buildDismissBackground(
          Alignment.centerRight,
          theme.colorScheme.error,
          Icons.delete,
        ),
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(context),
          const SizedBox(height: 20),
          _buildGameList(),
        ],
      ),
    );
  }

  Padding _buildCardHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kebabToCapitalized(widget.title),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isNotificationEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: isNotificationEnabled ? theme.primaryColor : theme.iconTheme.color,
            ),
            onPressed: () => _toggleNotification(widget.title, widget.subtitle),
          ),
        ],
      ),
    );
  }

  SizedBox _buildGameList() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          Game game = widget.items[index];
          return _buildGameItem(context, game);
        },
      ),
    );
  }

  GestureDetector _buildGameItem(BuildContext context, Game game) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (game.url != null && game.url!.isNotEmpty) {
          final pageProvider = Provider.of<PageProvider>(context, listen: false);

          pageProvider.setExtraPage(GameWebViewPage(url: game.url!, game: game),
          );
        }
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                game.imageurl ?? '',
                fit: BoxFit.cover,
                width: 250,
                height: 200,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                game.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<bool> _confirmDismiss(DismissDirection direction, BuildContext context) async {
    final savedSearchesProvider = Provider.of<SavedSearchesProvider>(context, listen: false);

    final bookmarkProvider = Provider.of<SearchBookmarkProvider>(context, listen: false);

    if (direction == DismissDirection.endToStart) {
      bool response = await _showConfirmDialog(
          context, "Confirm Deletion", "Are you sure you want to delete this saved search?",
              () async {
                await savedSearchesProvider.deleteSavedSearch(
                    widget.title, widget.subtitle);
                await bookmarkProvider.reloadBookMarkProvider();
              }
              ) ??
          false;

      if(response) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search deleted successfully')),
        );
      }

      return response;

    } else {
      bool response =  await _showConfirmDialog(
          context, "Confirm Search", "Are you sure you want to perform this search?", _goToSearch) ??
          false;

      return response;
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content, Future<void> Function() onConfirm) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await onConfirm();
                Navigator.of(context).pop(true);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDismissBackground(Alignment alignment, Color color, IconData icon) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      color: color,
      child: Icon(icon, color: Colors.white),
    );
  }

  void _toggleNotification(String type, String filters) async {
    final savedSearchesProvider = Provider.of<SavedSearchesProvider>(context, listen: false);

    String topicName = _generateTopicHash(type, filters);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    if (isNotificationEnabled) {
      await notificationService.unsubscribeFromTopic(topicName);
    } else {
      await notificationService.subscribeToTopic(topicName);
    }

    await savedSearchesProvider.changeNotifyField(type, filters, !isNotificationEnabled);
    setState(() {
      isNotificationEnabled = !isNotificationEnabled;
    });
  }

  String _generateTopicHash(String type, String filters) {
    String typeDefault = type;
    return sha256.convert(utf8.encode(typeDefault + filters)).toString();
  }

  Future<void> _goToSearch() async {
    Provider.of<PageProvider>(context, listen: false).navigateToIndexWithPage(1, SearchPage(initialTab: widget.title, initialFilters: widget.subtitle));
  }

  String _kebabToCapitalized(String kebab) {
    List<String> words = kebab.split('-');
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

