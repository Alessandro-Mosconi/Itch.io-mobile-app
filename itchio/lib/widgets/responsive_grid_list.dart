import 'package:flutter/material.dart';
import 'package:itchio/widgets/game_card.dart';
import '../helperClasses/Game.dart';

class ResponsiveGridList extends StatelessWidget {
  final List<Game> games;
  final bool isSearch;

  ResponsiveGridList({required this.games, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Tablet layout: grid
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              return GameCard(game: games[index]);
            },
          );
        } else {
          // Mobile layout: list
          return ListView(
            children: games.map((game) => GameCard(game: game)).toList(),
          );
        }
      },
    );
  }
}
