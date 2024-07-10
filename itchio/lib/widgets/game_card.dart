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

  GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orientation = MediaQuery
        .of(context)
        .orientation;
    final isLandscape = orientation == Orientation.landscape;

    String priceText = game.getFormatPriceWithCurrency();
    // Calcola le dimensioni dell'immagine in base all'orientamento
    final imageHeight = isLandscape
        ? 120.0
        : 200.0; // Valori esemplificativi, regola secondo necessità
    final imageWidth = double.infinity;

    // Ajusta la dimensione del testo in base all'orientamento
    final titleStyle = isLandscape ? theme.textTheme.headlineSmall?.copyWith(
        fontSize: 14) : theme.textTheme.headlineSmall;
    final descriptionStyle = isLandscape ? theme.textTheme.bodyMedium?.copyWith(
        fontSize: 12) : theme.textTheme.bodyMedium;

    return GestureDetector(
      key: const Key('game_card_gesture_detector'),
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
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.5),
        color: theme.canvasColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    game.imageurl ?? "https://via.placeholder.com/150",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                game.title ?? "No title",
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                game.getCleanDescription() ?? "No description",
                style: descriptionStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priceText,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
