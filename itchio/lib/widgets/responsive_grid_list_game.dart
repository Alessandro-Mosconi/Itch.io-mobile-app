import 'package:flutter/material.dart';
import 'package:itchio/widgets/game_card.dart';
import '../models/game.dart';

class ResponsiveGridListGame extends StatelessWidget {
  final List<Game> games;
  final bool isSearch;

  const ResponsiveGridListGame({super.key, required this.games, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 4 : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              return GameCard(game: games[index]);
            },
          );
        } else {
          return ListView(
            children: games.map((game) => GameCard(game: game)).toList(),
          );
        }
      },
    );
  }
}
