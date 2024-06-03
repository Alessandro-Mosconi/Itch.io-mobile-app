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

  Future<String> _showEventOptionDialog(BuildContext context, Jam jam) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildEventOptionDialog(context, jam);
      },
    ).then((value) => value ?? '');
  }

  AlertDialog _buildEventOptionDialog(BuildContext context, Jam jam) {
    return AlertDialog(
      title: Text(
        "Choose the event to save",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      content: _buildEventOptionContent(context, jam),
      actions: [_buildCancelButton(context)],
    );
  }

  Column _buildEventOptionContent(BuildContext context, Jam jam) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEventOptionButton(
          context,
          'duration',
          Colors.green,
          "Jam duration:\n${_formatDate(jam.startDate)}\n${_formatDate(jam.endDate)}",
        ),
        SizedBox(height: 16),
        _buildEventOptionButton(
          context,
          'votingEndDate',
          Colors.blue,
          "Voting end:\n${_formatDate(jam.votingEndDate)}",
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'n/a';
  }

  ElevatedButton _buildEventOptionButton(BuildContext context, String eventType, Color color, String text) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, eventType);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  TextButton _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context, '');
      },
      child: Text(
        "Cancel",
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  void _addToCalendar(BuildContext context, Jam jam) async {
    final result = await _showEventOptionDialog(context, jam);
    if (result.isEmpty) return;

    Event event = _createEvent(jam, result);
    Add2Calendar.addEvent2Cal(event);
  }

  Event _createEvent(Jam jam, String result) {
    String eventTitle = jam.title ?? 'Jam senza titolo';
    DateTime startDate;
    DateTime endDate;

    if (result == 'duration') {
      startDate = jam.startDate ?? DateTime.now();
      endDate = jam.endDate ?? DateTime.now().add(Duration(hours: 1));
    } else {
      eventTitle = "Ending vote $eventTitle";
      startDate = jam.votingEndDate ?? DateTime.now();
      endDate = jam.votingEndDate ?? DateTime.now();
    }

    return Event(
      title: eventTitle,
      description: 'Event description',
      location: 'Event location',
      startDate: startDate,
      endDate: endDate,
      iosParams: IOSParams(reminder: Duration(hours: 1)),
      androidParams: AndroidParams(emailInvites: []),
    );
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
            return _buildJamList(snapshot.data!);
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
        );
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

