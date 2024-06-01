import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helperClasses/Jam.dart';
import '../widgets/custom_app_bar.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

class JamsPage extends StatelessWidget {
  final Logger logger = Logger(printer: PrettyPrinter());

  Future<List<Jam>> fetchJams(bool? includeDetails) async {
    includeDetails ??= false;
    final prefs = await SharedPreferences.getInstance();
    var key = includeDetails ? "saved_jams_details" : "saved_jams";

    if (prefs.getString(key) != null &&
        checkTimestamp(prefs.getInt("${key}_timestamp"))) {
      String body = prefs.getString(key)!;
      List<dynamic>? results = json.decode(body);

      List<Jam> savedJams =
          results?.map((r) => Jam(r)).toList() ?? [];

      return savedJams;
    }

    final response = await http.get(
      Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/fetch_jams?include_details=$includeDetails'),
    );
    if (response.statusCode == 200) {
      List<dynamic>? results = json.decode(response.body);

      List<Jam> savedSearches =
          results?.map((r) => Jam(r)).toList() ?? [];

      prefs.setString(key, response.body);
      prefs.setInt(
          "${key}_timestamp", DateTime.now().millisecondsSinceEpoch);

      return savedSearches;
    } else {
      throw Exception('Failed to load saved jams results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<Jam>>(
        future: fetchJams(false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Jam>? jams = snapshot.data;
            if (jams != null && jams.isNotEmpty) {
              return ListView.builder(
                itemCount: jams.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(jams[index].title!),
                  );
                },
              );
            } else {
              return Center(
                child: Text('No jams found'),
              );
            }
          }
        },
      ),
    );
  }
}
