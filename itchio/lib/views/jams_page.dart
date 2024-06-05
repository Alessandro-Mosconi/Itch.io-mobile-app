import 'dart:async';
import 'dart:convert';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../helperClasses/Jam.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/jam_card.dart';

class JamsPage extends StatelessWidget {
  final Logger logger = Logger(printer: PrettyPrinter());

  Future<List<Jam>> fetchJams(bool? includeDetails) async {
    includeDetails ??= false;
    final prefs = await SharedPreferences.getInstance();
    var key = includeDetails ? "saved_jams_details" : "saved_jams";

    if (prefs.getString(key) != null && checkTimestamp(prefs.getInt("${key}_timestamp"))) {
      return _getCachedJams(prefs, key);
    }

    return _fetchJamsFromNetwork(key, includeDetails, prefs);
  }

  Future<List<Jam>> _getCachedJams(SharedPreferences prefs, String key) async {
    String body = prefs.getString(key)!;
    List<dynamic>? results = json.decode(body);
    return results?.map((r) => Jam(r)).toList() ?? [];
  }

  Future<List<Jam>> _fetchJamsFromNetwork(String key, bool includeDetails, SharedPreferences prefs) async {
    final response = await http.get(Uri.parse('https://us-central1-itchioclientapp.cloudfunctions.net/fetch_jams?include_details=$includeDetails'));

    if (response.statusCode == 200) {
      List<dynamic>? results = json.decode(response.body);
      prefs.setString(key, response.body);
      prefs.setInt("${key}_timestamp", DateTime.now().millisecondsSinceEpoch);
      return results?.map((r) => Jam(r)).toList() ?? [];
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  var orientation = MediaQuery.of(context).orientation;
                  bool isPortrait = orientation == Orientation.portrait;
                  return _buildJamGrid(snapshot.data!, isPortrait);
                } else {
                  // Phone layout: ListView
                  return _buildJamList(snapshot.data!);
                }
              },
            );
          } else {
            return Center(child: Text('No jams found'));
          }
        },
      ),
    );
  }

  ListView _buildJamList(List<Jam> jams) {
    return ListView.builder(
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(
          jam: jams[index],
          isTablet: false,
        );
      },
    );
  }

  GridView _buildJamGrid(List<Jam> jams, bool isPortrait) {
    double itemWidth = 500.0;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: itemWidth,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 16/9
      ),
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(jam: jams[index], isTablet: !isPortrait);
      },
    );
  }

  bool checkTimestamp(int? timestamp) {
    if (timestamp == null) return false;
    final cacheDuration = Duration(hours: 24);
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp < cacheDuration.inMilliseconds;
  }
}
