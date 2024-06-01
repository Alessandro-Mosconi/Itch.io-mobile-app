import 'dart:async';
import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helperClasses/Jam.dart';
import '../widgets/custom_app_bar.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

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

  Future<String> _showEventOptionDialog(BuildContext context, Jam jam) {
    Completer<String> completer = Completer<String>();

    showDialog<String>(
      context: context,
      barrierDismissible: false, // Impedisce di chiudere il dialogo toccando fuori
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Choose the event to save",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  completer.complete('duration');
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Jam duration:\n${DateFormat('dd/MM/yyyy HH:mm').format(jam.startDate!)}\n${jam.endDate != null ? DateFormat('dd/MM/yyyy HH:mm').format(jam.endDate!) : 'n/a'}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  completer.complete('votingEndDate');
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Voting end:\n${DateFormat('dd/MM/yyyy HH:mm').format(jam.votingEndDate!)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                completer.complete('');
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  void _addToCalendar( BuildContext context, Jam jam) async {
    final result = await _showEventOptionDialog(context, jam);

    logger.i(result);

    String eventTitle = jam.title ?? 'Jam senza titolo';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    if (result == 'duration') {
      startDate = jam.startDate ?? DateTime.now();
      endDate = jam.endDate ?? DateTime.now().add(Duration(hours: 1));
    } else if (result == 'votingEndDate') {
      eventTitle = "Ending vote ${eventTitle}";
      startDate = jam.votingEndDate ?? DateTime.now();
      endDate = jam.votingEndDate ?? DateTime.now();
    } else {
      return;
    }

    final Event event = Event(
      title: eventTitle,
      description: 'Event description',
      location: 'Event location',
      startDate: startDate,
      endDate: endDate,
      iosParams: IOSParams(
        reminder: Duration(hours:1),
      ),
      androidParams: AndroidParams(
        emailInvites: [],
      ),
    );

    Add2Calendar.addEvent2Cal(event);
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
                  Jam jam = jams[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Text(
                                jam.title ?? '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(Icons.date_range, 'Start:', jam.startDate, Colors.green),
                                    SizedBox(height: 5),
                                    _buildInfoRow(Icons.event, 'End:', jam.endDate, Colors.red),
                                    SizedBox(height: 5),
                                    _buildInfoRow(Icons.how_to_vote, 'Voting Ends:', jam.votingEndDate, Colors.blue),
                                    SizedBox(height: 5),
                                    _buildInfoRow(Icons.people, 'Participants:', jam.joined.toString(), Colors.orange),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () {
                              _addToCalendar(context, jam);
                            },
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildInfoRow(IconData icon, String label, dynamic value, Color color) {
    String displayValue;
    if (value is DateTime) {
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      displayValue = formatter.format(value);
    } else {
      displayValue = value.toString();
    }

    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 5),
        Text(
          '$label $displayValue',
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}

class JamDetailPage extends StatelessWidget {
  final String url;

  JamDetailPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Text('Opening URL: https://itch.io$url'),
      ),
    );
  }
}
