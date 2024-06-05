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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

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
        color: theme.cardColor,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: isTablet ? 300 : 200,
                  width: double.infinity,
                  child: Image.network(
                    game.imageurl ?? "https://via.placeholder.com/150",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  game.title ?? "Default Title",
                  style: theme.textTheme.headline6,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  game.getCleanDescription() ?? "No description",
                  style: theme.textTheme.bodyText2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    if (game.p_windows ?? false)
                      Icon(CustomIcon.windows, size: 16, color: theme.iconTheme.color),
                    if (game.p_osx ?? false)
                      Icon(Icons.apple, size: 24, color: theme.iconTheme.color),
                    if (game.p_linux ?? false)
                      Icon(CustomIcon.linux, size: 16, color: theme.iconTheme.color),
                    if (game.p_android ?? false)
                      Icon(Icons.android, size: 24, color: theme.iconTheme.color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
