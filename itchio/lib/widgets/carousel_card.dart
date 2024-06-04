import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helperClasses/Game.dart';
import '../providers/page_provider.dart';
import '../views/game_webview_page.dart';
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

  @override
  void initState() {
    super.initState();
    isNotificationEnabled = widget.notify;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Dismissible(
        key: Key(widget.title),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) => _confirmDismiss(direction, context),
        background: _buildDismissBackground(Alignment.centerLeft, Colors.blue, Icons.search),
        secondaryBackground: _buildDismissBackground(Alignment.centerRight, Colors.red, Icons.delete),
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardHeader(context),
        _buildGameList(),
      ],
    );
  }

  Padding _buildCardHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kebabToCapitalized(widget.title),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(widget.subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isNotificationEnabled ? Icons.notifications_active : Icons.notifications,
              color: isNotificationEnabled ? Colors.amber : Colors.grey,
            ),
            onPressed: () => _toggleNotification(widget.title, widget.subtitle),
          ),
        ],
      ),
    );
  }

  SizedBox _buildGameList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
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
    return GestureDetector(
      onTap: () {
        if (game.url != null && game.url!.isNotEmpty) {
          Provider.of<PageProvider>(context, listen: false).setExtraPage(GameWebViewPage(url: game.url!, game: game));
        } else {
          throw 'Could not launch ${game.url}';
        }
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                game.imageurl ?? '',
                fit: BoxFit.cover,
                width: 160,
                height: 140,
              ),
            ),
            SizedBox(height: 8),
            Text(
              game.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(DismissDirection direction, BuildContext context) async {
    if (direction == DismissDirection.endToStart) {
      return await _showConfirmDialog(context, "Confirm Deletion", "Are you sure you want to delete this saved search?") ?? false;
    } else {
      return await _showConfirmDialog(context, "Confirm Search", "Are you sure you want to perform this search?") ?? false;
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content) {
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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
    await changeNotifyField(type, filters, !isNotificationEnabled);
    setState(() {
      isNotificationEnabled = !isNotificationEnabled;
    });
  }

  Future<void> changeNotifyField(String type, String filters, bool notify) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');
    String typeDefault = type;
    String key = sha256.convert(utf8.encode(typeDefault + filters)).toString();
    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.update({
      "filters": filters,
      "type": typeDefault,
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

  Future<void> deleteSavedSearch(String type, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');
    String typeDefault = type;
    String key = sha256.convert(utf8.encode(typeDefault + filters)).toString();
    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.remove();
    String body = prefs.getString("saved_searches")!;
    List<dynamic> results = json.decode(body);
    results.removeWhere((r) {
      return r['type'] == type && r['filters'] == filters;
    });
    prefs.setString("saved_searches", json.encode(results));
  }

  String _kebabToCapitalized(String kebab) {
    List<String> words = kebab.split('-');
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

