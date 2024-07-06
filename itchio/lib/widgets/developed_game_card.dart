import 'package:flutter/material.dart';
import '../models/game.dart';
import 'game_card.dart';

class DevelopedGameCard extends StatelessWidget {
  final Game game;

  const DevelopedGameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GameCard(game: game),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildStatColumn("Views", game.views_count ?? 0, Colors.red),
                _buildStatColumn("Downloads", game.downloads_count ?? 0, Colors.green),
                if (game.purchases_count != 0)
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
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
