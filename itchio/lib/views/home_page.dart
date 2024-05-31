import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:itchio/helperClasses/SavedSearch.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;

import '../helperClasses/Game.dart';

final Logger logger = Logger(printer: PrettyPrinter());

bool checkTimestamp(int? timestamp){
  // 172800000 = 2 days in ms
  return (timestamp == null) || ((timestamp + 172800000) > DateTime.now().millisecondsSinceEpoch);
}

Future<List<SavedSearch>> fetchSavedSearch() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("access_token");

  if(prefs.getString("saved_searches") != null && checkTimestamp(prefs.getInt("saved_searches_timestamp"))){

    String body = prefs.getString("saved_searches")!;
    List<dynamic>? results = json.decode(body);

    List<SavedSearch> savedSearches = results?.map((r) => SavedSearch(r)).toList() ?? [];

    return savedSearches;
  }

  final response = await http.post(
    Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/get_saved_search_carousel'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'token': token}),
  );

  if (response.statusCode == 200) {
    List<dynamic>? results = json.decode(response.body);

    List<SavedSearch> savedSearches = results?.map((r) => SavedSearch(r)).toList() ?? [];
    prefs.setString("saved_searches", response.body);
    prefs.setInt("saved_searches_timestamp", DateTime.now().millisecondsSinceEpoch);

    return savedSearches;
  } else {
    throw Exception('Failed to load saved search results');
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SavedSearch>> futureSavedSearches;

  @override
  void initState() {
    super.initState();
    futureSavedSearches = fetchSavedSearch();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<SavedSearch>>(
        future: futureSavedSearches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load saved search results'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved searches found'));
          } else {
            List<SavedSearch> savedSearches = snapshot.data!;
            return ListView.builder(
              itemCount: savedSearches.length,
              itemBuilder: (context, index) {
                SavedSearch search = savedSearches[index];
                return CarouselCard(
                  title: search.type ?? '',
                  subtitle: search.filters ?? '',
                  items: search.items ?? [],
                  notify: search.notify ?? false,
                );
              },
            );
          }
        },
      ),
    );
  }
}
String kebabToCapitalized(String kebab) {
  List<String> words = kebab.split('-');

  String capitalized = words.map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');

  return capitalized;
}
Future<void> changeNotifyField(String type, String filters, bool notify) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("access_token");

  final firebaseApp = Firebase.app();
  final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

  String typeDefault = type ?? 'games';

  String key = sha256.convert(utf8.encode(typeDefault + filters)).toString();

  final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
  await dbRef.update(
      {
        "filters" : filters,
        "type": typeDefault,
        "notify": notify
      }
  );

  String body = prefs.getString("saved_searches")!;
  List<dynamic> results = json.decode(body) ?? [];

  results = results.map((r){
    if(r['type'] == type && r['filters']==filters){
      r['notify'] = notify;
    }
    return r;
  }).toList();
  prefs.setString("saved_searches", json.encode(results));
}


class CarouselCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Game> items;
  final bool notify;

  CarouselCard({
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
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    isNotificationEnabled = widget.notify;
  }

  void _toggleNotification(String type, String filters) {
    changeNotifyField(type, filters, !isNotificationEnabled);
    setState(() {
      isNotificationEnabled = !isNotificationEnabled;
    });
  }


  Future<void> deleteSavedSearch(String type, String filters) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    String typeDefault = type ?? 'games';

    String key = sha256.convert(utf8.encode(typeDefault + filters)).toString();

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}/$key');
    await dbRef.remove();

    String body = prefs.getString("saved_searches")!;
    List<dynamic> results = json.decode(body) ?? [];

    results.removeWhere((r) {
      return r['type'] == type && r['filters']==filters;
    });

    prefs.setString("saved_searches", json.encode(results));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Dismissible(
        key: Key(widget.title), // Unique key for the Dismissible widget
        direction: DismissDirection.horizontal, // Allow both left and right swipes
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Deletion"),
                  content: Text("Are you sure you want to delete this saved search?"),
                  actions: <Widget>[
                    MaterialButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Cancel"),
                    ),
                    MaterialButton(
                      onPressed: () =>
                          {
                            deleteSavedSearch(widget.title, widget.subtitle),
                            Navigator.of(context).pop(true),
                          },
                      child: Text("Confirm"),
                    ),
                  ],
                );
              },
            );
          } else {
            // Swipe from left to right (search action)
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Search"),
                  content: Text("Are you sure you want to perform this search?"),
                  actions: <Widget>[
                    MaterialButton(
                      onPressed: () => Navigator.of(context).pop(false), // Cancel
                      child: Text("Cancel"),
                    ),
                    MaterialButton(
                      onPressed: () => Navigator.of(context).pop(true), // Confirm
                      child: Text("Confirm"),
                    ),
                  ],
                );
              },
            );
          }
        },
        onDismissed: (direction) {
          // Code to handle dismiss actions (not needed for swipe confirmation)
          if (direction == DismissDirection.endToStart) {
            // Perform delete action here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Search deleted"),
              ),
            );
          }
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20.0),
          color: Colors.blue,
          child: Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kebabToCapitalized(widget.title),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isNotificationEnabled ? Icons.notifications_active : Icons.notification_add_outlined,
                      color: isNotificationEnabled ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => _toggleNotification(widget.title, widget.subtitle),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,  // Increased height for larger images
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  Game game = widget.items[index];
                  return Container(
                    width: 160,  // Increased width
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
                            height: 140,  // Increased height
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          game.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
