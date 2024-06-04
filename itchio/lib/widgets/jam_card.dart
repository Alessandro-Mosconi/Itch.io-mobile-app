import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../helperClasses/Jam.dart';
import '../providers/page_provider.dart';
import '../views/game_webview_page.dart';
import 'package:provider/provider.dart';

class JamCard extends StatelessWidget {
  final Jam jam;
  final bool isTablet;

  JamCard({required this.jam, required this.isTablet});

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
                  subtitle: JamInfo(jam: jam, isTablet: isTablet),
                ),
              ],
            ),
            if (jam.endDate != null || jam.startDate != null || jam.votingEndDate != null)
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _addToCalendar(context, jam),
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
  final bool isTablet;
  final Logger logger = Logger(printer: PrettyPrinter());

  JamInfo({required this.jam, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTablet) _buildTabletLayout(
                  context,
                  _buildInfoRow(Icons.date_range, 'Start:', jam.startDate, Colors.green),
                  _buildInfoRow(Icons.event, 'End:', jam.endDate, Colors.red)) else _buildPhoneLayout(
                  context,
                  _buildInfoRow(Icons.date_range, 'Start:', jam.startDate, Colors.green),
                  _buildInfoRow(Icons.event, 'End:', jam.endDate, Colors.red)),
              SizedBox(height: 5),
              if (isTablet) _buildTabletLayout(context,
                _buildInfoRow(Icons.how_to_vote, 'Voting Ends:', jam.votingEndDate, Colors.blue),
                _buildInfoRow(Icons.people, 'Participants:', jam.joined.toString(), Colors.orange)
              ) else _buildPhoneLayout(context,
                _buildInfoRow(Icons.how_to_vote, 'Voting Ends:', jam.votingEndDate, Colors.blue),
                _buildInfoRow(Icons.people, 'Participants:', jam.joined.toString(), Colors.orange),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneLayout(BuildContext context, Widget infoRow1 , Widget infoRow2) {
    return Column(
      children: [
        infoRow1,
        SizedBox(height: 5),
        infoRow2,
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, Widget infoRow1 , Widget infoRow2) {
    return Row(
      children: [
        Expanded(child: infoRow1),
        Expanded(child: infoRow2),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            '$label ${_formatInfoValue(value)}',
            style: TextStyle(color: color),
            overflow: TextOverflow.visible,
          ),
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
