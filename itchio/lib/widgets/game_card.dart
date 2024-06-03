import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../helperClasses/Game.dart';
import '../customIcons/custom_icon_icons.dart';
import '../views/game_webview_page.dart';
import '../providers/page_provider.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final Logger logger = Logger(printer: PrettyPrinter());

  GameCard({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (game.url != null && game.url!.isNotEmpty) {
          Provider.of<PageProvider>(context, listen: false).setExtraPage(
            GameWebViewPage(
              url: game.url!,
              game: game,
            ),
          );
        } else {
          logger.i('Could not launch ${game.url}');
          throw 'Could not launch ${game.url}';
        }
      },
      child: Card(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 600;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Image.network(
                      game.imageurl ?? "https://via.placeholder.com/150",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    game.title ?? "Default Title",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    game.getCleanDescription() ?? "No description",
                    style: TextStyle(fontSize: 14),
                    maxLines: isTablet ? 2 : 1, // Limit lines based on screen size
                    overflow: TextOverflow.ellipsis, // Truncate with ellipsis
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
                  SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
