import 'package:flutter/material.dart';
import '../models/game.dart';
import 'game_card.dart';

class DevelopedGameCard extends StatelessWidget {
  final Game game;

  DevelopedGameCard({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GameCard(game: game),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildStatColumn("Views", game.views_count ?? 0, Colors.red),
                _buildStatColumn("Downloads", game.downloads_count ?? 0, Colors.green),
                _buildStatColumn("Purchases", game.purchases_count ?? 0, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              "$count",
              style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
