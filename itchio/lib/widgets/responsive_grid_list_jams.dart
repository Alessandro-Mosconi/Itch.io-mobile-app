import 'package:flutter/material.dart';
import 'package:itchio/widgets/game_card.dart';
import '../models/game.dart';
import '../models/jam.dart';
import 'jam_card.dart';

class ResponsiveGridListJam extends StatelessWidget {
  final List<Jam> jams;

  const ResponsiveGridListJam({super.key, required this.jams});

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (jams.isEmpty) {
          return const Center(child: Text('No jams found'));
        }

        if (constraints.maxWidth > 600) {
          var orientation = MediaQuery.of(context).orientation;
          bool isPortrait = orientation == Orientation.portrait;
          return _buildJamGrid(jams, isPortrait);
        } else {
          return _buildJamList(jams);
        }
      },
    );
  }

  ListView _buildJamList(List<Jam> jams) {
    return ListView.builder(
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(
          jam: jams[index],
          isTablet: false,
        );
      },
    );
  }

  GridView _buildJamGrid(List<Jam> jams, bool isPortrait) {
    double itemWidth = 500.0;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: itemWidth,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 16 / 9,
      ),
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(jam: jams[index], isTablet: !isPortrait);
      },
    );
  }
}
