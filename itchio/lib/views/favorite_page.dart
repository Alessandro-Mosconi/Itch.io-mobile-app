import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helperClasses/Jam.dart';
import '../providers/favorite_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/game_card.dart';
import '../widgets/jam_card.dart';

class FavoritePage extends StatefulWidget {
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
          title: CustomAppBar(),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
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
                  Center(child: Text('Nessun gioco preferito ancora'))
                else
                  ListView.builder(
                    itemCount: favoriteProvider.favoriteGames.length,
                    itemBuilder: (context, index) {
                      return GameCard(game: favoriteProvider.favoriteGames[index]);
                    },
                  ),
                if (favoriteProvider.favoriteJams.isEmpty)
                  Center(child: Text('Nessuna jam preferita ancora'))
                else
                  _buildJamList(favoriteProvider.favoriteJams),
              ],
            );
          },
        ),
      ),
    );
  }

  ListView _buildJamList(List<Jam> jams) {
    return ListView.builder(
      itemCount: jams.length,
      itemBuilder: (context, index) {
        return JamCard(
          jam: jams[index],
        );
      },
    );
  }


}
