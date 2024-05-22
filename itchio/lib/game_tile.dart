import 'package:flutter/material.dart';
import 'helperClasses/Game.dart';
import 'customIcons/custom_icon_icons.dart';

class GameTile extends StatelessWidget {
  final Game game;

  const GameTile({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.network(
                  game.cover_url ?? "https://via.placeholder.com/50", // Default image URL
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              game.title ?? "Default Title",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            game.min_price == 0
                                ? "Free"
                                : "${(game.min_price != null ? game.min_price! / 100 : 0).toStringAsFixed(2)} €",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: game.min_price == 0 ? Colors.green : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        game.short_text ?? "No description",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          if (game.p_windows ?? false) Icon(CustomIcon.windows, size: 16, color: Colors.grey),
                          if (game.p_osx ?? false) Icon(Icons.apple, size: 24, color: Colors.grey),
                          if (game.p_linux ?? false) Icon(CustomIcon.linux, size: 16, color: Colors.grey),
                          if (game.p_android ?? false) Icon(Icons.android, size: 24, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
