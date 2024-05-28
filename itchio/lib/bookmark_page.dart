import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_app_bar.dart';
import 'package:http/http.dart' as http;

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {

  late SharedPreferences prefs;
  final Logger logger = Logger(printer: PrettyPrinter());
  late List<Map<String, String>> data = [];

  Future<List<Map<String, String>>> fetchFavorites() async {
    prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final firebaseApp = Firebase.app();
    final dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://itchioclientapp-default-rtdb.europe-west1.firebasedatabase.app');

    final DatabaseReference dbRef = dbInstance.ref('/user_search/' + token!);
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final dynamic rawData = snapshot.value;
      final List<Map<String, String>> dataList = [];

      if (rawData is List<dynamic>) {
        for (final item in rawData) {
          if (item is Map<Object?, Object?>) {
            final Map<String, String> search = {
              'filters': item['filters'].toString(),
              'type': item['type'].toString(),
            };
            dataList.add(search);
          }
        }
      }

      logger.i(dataList);
      return dataList;
    }
    return [];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ricerche Salvate'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Le tue ricerche salvate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: fetchFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else {
                  final data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final search = data[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              search['type']!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(search['filters']!),
                            onTap: () {
                              // Azioni quando l'utente tocca una ricerca salvata
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
