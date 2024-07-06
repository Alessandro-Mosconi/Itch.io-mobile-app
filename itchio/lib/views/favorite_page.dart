import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/jam.dart';
import '../providers/favorite_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/game_card.dart';
import '../widgets/jam_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    await Future.wait([
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavoriteGames(),
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavoriteJams(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const CustomAppBar(
            leading: null, // If you have a leading widget, set it here
            actions: [], // If you have actions, set them here
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Games'),
              Tab(text: 'Jams'),
            ],
          ),
        ),
        body: Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                if (favoriteProvider.favoriteGames.isEmpty)
                  const Center(child: Text('Nessun gioco preferito ancora'))
                else
                  _buildGameGrid(favoriteProvider.favoriteGames, context),
                if (favoriteProvider.favoriteJams.isEmpty)
                  const Center(child: Text('Nessuna jam preferita ancora'))
                else
                  _buildJamGrid(favoriteProvider.favoriteJams, context),
              ],
            );
          },
        ),
      ),
    );
  }

  GridView _buildGameGrid(List<Game> games, BuildContext context) {
    double aspectRatio = _getChildAspectRatio(context, true);
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 1;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: aspectRatio,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameCard(game: games[index]);
      },
    );
  }

  GridView _buildJamGrid(List<Jam> jams, BuildContext context) {
    double aspectRatio = _getChildAspectRatio(context, false);
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 1;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: aspectRatio,
      ),
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(
          jam: jams[index],
          isTablet: false,
        );
      },
    );
  }

  double _getChildAspectRatio(BuildContext context, bool isGame) {
    double width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    if (width > 1200) {
      return orientation == Orientation.landscape ? 1.5 : 1;
    } else if (width > 600) {
      return orientation == Orientation.landscape ? 0.95 : 1.2;
    } else {
      return isGame ? 0.9 :1.5;
    }
  }
}
