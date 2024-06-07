import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/game.dart';
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

    String priceText = game.getFormatPriceWithCurrency();

    return GestureDetector(
      key: Key('game_card_gesture_detector'),
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
          //throw 'Could not launch ${game.url}';
        }
      },
      child: Card(
        margin: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.5),
        color: theme.canvasColor,  // Change this line to make the background white
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: isTablet ? 300 : 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    game.imageurl ?? "https://via.placeholder.com/150",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                game.title ?? "Default Title",
                style: theme.textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                game.getCleanDescription() ?? "No description",
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20),
              Row(
                children: [
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
                  Spacer(), // Push the price chip to the right
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2), // Use a fixed background color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priceText,
                      style: TextStyle(
                        color: Colors.blue, // Use a fixed text color
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Increase font size
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
