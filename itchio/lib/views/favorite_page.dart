import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/jam.dart';
import '../providers/favorite_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/game_card.dart';
import '../widgets/jam_card.dart';
import '../widgets/responsive_grid_list_game.dart';
import '../widgets/responsive_grid_list_jams.dart';
import 'package:lottie/lottie.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _lottieController.repeat(reverse: true);
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
    _lottieController.dispose();
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
            leading: null,
            actions: [],
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
                favoriteProvider.favoriteGames.isEmpty
                    ? _buildEmptyStateWidget('No favorite games yet', 'Start exploring and save your favorite games!')
                    : ResponsiveGridListGame(games: favoriteProvider.favoriteGames),
                favoriteProvider.favoriteJams.isEmpty
                    ? _buildEmptyStateWidget('No favorite jams yet', 'Join game jams and save them as favorites!')
                    : ResponsiveGridListJam(jams: favoriteProvider.favoriteJams)
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget(String title, String message) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/81ee35fc-7d8f-4356-81fc-801e078d7014/jETcdSHcKj.json',
              controller: _lottieController,
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}