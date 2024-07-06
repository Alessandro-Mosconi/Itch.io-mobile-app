import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../models/jam.dart';
import '../providers/page_provider.dart';
import '../views/game_webview_page.dart';
import 'package:provider/provider.dart';

class JamCard extends StatelessWidget {
  final Jam jam;
  final bool isTablet;

  const JamCard({super.key, required this.jam, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      key: const Key('jam_card_gesture_detector'),
      onTap: () => _navigateToJam(context, jam),
      child: Card(
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.5),
        color: theme.canvasColor,
        child: Stack(
          children: [
            Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  title: Text(jam.title ?? '', style: theme.textTheme.headlineSmall),
                  subtitle: JamInfo(jam: jam, isTablet: isTablet),
                ),
              ],
            ),
            if (jam.endDate != null || jam.startDate != null || jam.votingEndDate != null)
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
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
    String eventTitle = jam.title ?? 'Untitled Jam';
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
      iosParams: const IOSParams(reminder: Duration(hours: 1)),
      androidParams: const AndroidParams(emailInvites: []),
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
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        "Choose the event to save",
        style: theme.textTheme.headlineSmall,
      ),
      content: _buildEventOptionContent(context, jam),
      actions: [_buildCancelButton(context)],
    );
  }

  Column _buildEventOptionContent(BuildContext context, Jam jam) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (jam.startDate != null && jam.endDate != null)
          _buildEventOptionButton(
            context,
            'duration',
            theme.primaryColor,
            "Jam duration:\n${_formatDate(jam.startDate)}\n${_formatDate(jam.endDate)}",
          ),
        const SizedBox(height: 16),
        if (jam.votingEndDate != null)
          _buildEventOptionButton(
            context,
            'votingEndDate',
            theme.colorScheme.secondary,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  TextButton _buildCancelButton(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        Navigator.pop(context, '');
      },
      child: Text(
        "Cancel",
        style: theme.textTheme.labelLarge,
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

  JamInfo({super.key, required this.jam, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTablet)
                _buildTabletLayout(
                  context,
                  _buildInfoRow(Icons.date_range, 'Start:', jam.startDate, theme.primaryColor),
                  _buildInfoRow(Icons.event, 'End:', jam.endDate, theme.colorScheme.error),
                )
              else
                _buildPhoneLayout(
                  context,
                  _buildInfoRow(Icons.date_range, 'Start:', jam.startDate, theme.primaryColor),
                  _buildInfoRow(Icons.event, 'End:', jam.endDate, theme.colorScheme.error),
                ),
              const SizedBox(height: 5),
              if (isTablet)
                _buildTabletLayout(
                  context,
                  _buildInfoRow(Icons.how_to_vote, 'Voting Ends:', jam.votingEndDate, theme.colorScheme.secondary),
                  _buildInfoRow(Icons.people, 'Participants:', jam.joined.toString(), theme.colorScheme.primary),
                )
              else
                _buildPhoneLayout(
                  context,
                  _buildInfoRow(Icons.how_to_vote, 'Voting Ends:', jam.votingEndDate, theme.colorScheme.secondary),
                  _buildInfoRow(Icons.people, 'Participants:', jam.joined.toString(), theme.colorScheme.primary),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneLayout(BuildContext context, Widget infoRow1, Widget infoRow2) {
    return Column(
      children: [
        infoRow1,
        const SizedBox(height: 5),
        infoRow2,
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, Widget infoRow1, Widget infoRow2) {
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
        const SizedBox(width: 5),
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
