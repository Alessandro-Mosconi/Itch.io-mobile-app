import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../helperClasses/Game.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late SharedPreferences prefs;
  final Logger logger = Logger(printer: PrettyPrinter());
  late List<Map<String, String>> data = [];
  late List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/user_search/${token!}');
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic rawData = snapshot.value;
      final List<Map<String, String>> dataList = [];

      if (rawData is Map<Object?, Object?>) {
        for (final item in rawData.values) {
          if (item is Map<Object?, Object?>) {
            final Map<String, String> search = {
              'filters': item['filters'].toString(),
              'type': item['type'].toString(),
            };
            dataList.add(search);
          }
        }
      }

      setState(() {
        data = dataList;
        _isExpandedList = List<bool>.filled(dataList.length, false);
      });
    }
  }

  Future<Map<String, dynamic>> fetchresearchResult(String type, String filters) async {
    String? result = prefs.getString('research_${type}_$filters');

    if (result != null) {
      return json.decode(result);
    } else {
      final response = await http.post(
        Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/item_list'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'filters': filters, 'type': type}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        prefs.setString('research_${type}_$filters', response.body);
        return responseData;
      } else {
        logger.e('Type: $type, Filters: $filters');
        logger.e('Failed to load tab results, status code: ${response.statusCode}');
        throw Exception('Failed to load tab results');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ricerche Salvate'),
      ),
      body: ListView(
        children: [
          ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _isExpandedList[index] = isExpanded;
              });
            },
            children: data.map<ExpansionPanel>((search) {
              final index = data.indexOf(search);
              return ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      search['type']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(search['filters']!),
                  );
                },
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            // Azione per aprire la ricerca
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Azione per eliminare la ricerca
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications),
                          onPressed: () {
                            // Azione per attivare/disattivare notifiche
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 200, // Altezza fissa per il carosello di immagini
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          FutureBuilder<Map<String, dynamic>>(
                            future: fetchresearchResult(search['type']!, search['filters']!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('Game loading...');
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final List<Game> images = (snapshot.data?['items'] as List).map((game) => Game(game)).toList();
                                return Row(
                                  children: images.map<Widget>((game) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                        game.imageurl ?? '',
                                        width: 150, // Imposta la larghezza desiderata per le immagini
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                    ),
                  ],
                ),
                isExpanded: _isExpandedList[index],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
