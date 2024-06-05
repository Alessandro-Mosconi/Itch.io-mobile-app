import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helperClasses/Game.dart';
import '../providers/page_provider.dart';
import '../views/game_webview_page.dart';
import '../services/notification_service.dart';
import '../views/search_page.dart';

class CarouselCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Game> items;
  final bool notify;
  final Function(bool) onUpdateSavedSearches;

  CarouselCard({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.notify,
    required this.onUpdateSavedSearches,
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
    _scrollTimer = Timer.periodic(Duration(seconds: 4), (timer) async {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final delta = 200.0; // Adjust the scroll amount as needed

        if (currentScroll + delta >= maxScroll) {
          await _scrollController.animateTo(
            0.0,
            duration: Duration(seconds: 3),
            curve: Curves.easeInOut,
          );
        } else {
          await _scrollController.animateTo(
            currentScroll + delta,
            duration: Duration(seconds: 3),
            curve: Curves.easeInOut,
          );
        }

        // Introduce a random delay between 1 and 5 seconds
        final randomDelay = Duration(seconds: _random.nextInt(5) + 1);
        await Future.delayed(randomDelay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Dismissible(
        key: Key(widget.title),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) => _confirmDismiss(direction, context),
        background: _buildDismissBackground(Alignment.centerLeft, theme.primaryColor, Icons.search),
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(context),
          SizedBox(height: 20),
          _buildGameList(),
        ],
      ),
    );
  }

  Padding _buildCardHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kebabToCapitalized(widget.title),
                  style: theme.textTheme.headline5,
                ),
                SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: theme.textTheme.bodyText2,
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
          Provider.of<PageProvider>(context, listen: false).setExtraPage(
            GameWebViewPage(url: game.url!, game: game),
          );
        } else {
          throw 'Could not launch ${game.url}';
        }
      },
      child: Container(
        width: 250,
        margin: EdgeInsets.symmetric(horizontal: 5), //between items
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
            SizedBox(height: 8),
            Text(
              game.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(DismissDirection direction, BuildContext context) async {
    if (direction == DismissDirection.endToStart) {
      return await _showConfirmDialog(
          context, "Confirm Deletion", "Are you sure you want to delete this saved search?",
          deleteSavedSearch) ??
          false;
    } else {
      return await _showConfirmDialog(
          context, "Confirm Search", "Are you sure you want to perform this search?", _goToSearch) ??
          false;
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
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await onConfirm();
                Navigator.of(context).pop(true);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDismissBackground(Alignment alignment, Color color, IconData icon) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      color: color,
      child: Icon(icon, color: Colors.white),
    );
  }

  void _toggleNotification(String type, String filters) async {
    String topicName = _generateTopicHash(type, filters);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    if (isNotificationEnabled) {
      await notificationService.unsubscribeFromTopic(topicName);
    } else {
      await notificationService.subscribeToTopic(topicName);
    }

    await changeNotifyField(type, filters, !isNotificationEnabled);
    setState(() {
      isNotificationEnabled = !isNotificationEnabled;
    });
  }

  String _generateTopicHash(String type, String filters) {
    String typeDefault = type;
    return sha256.convert(utf8.encode(typeDefault + filters)).toString(); // key
  }

  Future<void> changeNotifyField(String type, String filters, bool notify) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');
    String key = _generateTopicHash(type, filters);
    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.update({
      "filters": filters,
      "type": type,
      "notify": notify
    });
    String body = prefs.getString("saved_searches")!;
    List<dynamic> results = json.decode(body);
    results = results.map((r) {
      if (r['type'] == type && r['filters'] == filters) {
        r['notify'] = notify;
      }
      return r;
    }).toList();
    prefs.setString("saved_searches", json.encode(results));
  }

  Future<void> deleteSavedSearch() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');
    String key = _generateTopicHash(widget.title, widget.subtitle);
    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.remove();
    String body = prefs.getString("saved_searches")!;
    List<dynamic> results = json.decode(body);
    results.removeWhere((r) {
      return r['type'] == widget.title && r['filters'] == widget.subtitle;
    });
    prefs.setString("saved_searches", json.encode(results));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search deleted successfully')),
    );
  }

  Future<void> _goToSearch() async {
    Navigator.of(context).pop(false);
    Provider.of<PageProvider>(context, listen: false).setSelectedIndex(1);
  }

  String _kebabToCapitalized(String kebab) {
    List<String> words = kebab.split('-');
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

