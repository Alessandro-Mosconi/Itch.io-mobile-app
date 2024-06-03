import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helperClasses/Jam.dart';
import '../helperClasses/Game.dart';
import '../providers/page_provider.dart';
import '../views/game_webview_page.dart';
import 'package:provider/provider.dart';

class JamCard extends StatelessWidget {
  final Jam jam;

  JamCard({required this.jam});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToJam(context, jam),
      child: Card(
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 5,
        child: Stack(
          children: [
            Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(jam.title ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: JamInfo(jam: jam),
                ),
              ],
            ),
            if(jam.endDate != null || jam.startDate != null || jam.votingEndDate != null)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => {
                  _addToCalendar(context, jam)
                },
              ),
            ),
          ],
        ),
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
      endDate = jam.endDate ?? startDate;
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
        if (jam.startDate != null && jam.endDate != null)
        _buildEventOptionButton(
          context,
          'duration',
          Colors.green,
          "Jam duration:\n${_formatDate(jam.startDate)}\n${_formatDate(jam.endDate)}",
        ),
        SizedBox(height: 16),
        if (jam.votingEndDate != null)
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
        backgroundColor: WidgetStateProperty.all<Color>(color),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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


  void _navigateToJam(BuildContext context, Jam jam) {
    if (jam.url != null && jam.url!.isNotEmpty) {
      Provider.of<PageProvider>(context, listen: false).setExtraPage(
        GameWebViewPage(
          url: 'https://itch.io${jam.url!}',
          jam: jam,
        ),
      );
    }
  }
}

class JamInfo extends StatelessWidget {
  final Jam jam;

  JamInfo({required this.jam});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }


  Widget _buildInfoRow(IconData icon, String label, dynamic value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 5),
        Text(
          '$label ${_formatInfoValue(value)}',
          style: TextStyle(color: color),
        ),
      ],
    );
  }

  String _formatInfoValue(dynamic value) {
    if (value is DateTime) {
      return DateFormat('dd MMM yyyy').format(value);
    } else {
      return value.toString();
    }
  }

}

