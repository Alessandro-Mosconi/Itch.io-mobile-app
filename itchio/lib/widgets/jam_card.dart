import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helperClasses/Jam.dart';
import '../helperClasses/Game.dart';
import '../providers/page_provider.dart';
import '../views/game_webview_page.dart';
import 'package:provider/provider.dart';

class JamCard extends StatelessWidget {
  final Jam jam;
  final VoidCallback onAddToCalendar;

  JamCard({required this.jam, required this.onAddToCalendar});

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
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: onAddToCalendar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToJam(BuildContext context, Jam jam) {
    if (jam.url != null && jam.url!.isNotEmpty) {
      Game game = Game({
        'url': jam.url,
        'title': jam.title,
        'short_text': 'Jam Description',
        'coverUrl': 'https://via.placeholder.com/150',
      });

      Provider.of<PageProvider>(context, listen: false).setExtraPage(
        GameWebViewPage(
          gameUrl: 'https://itch.io${jam.url!}',
          game: game,
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
