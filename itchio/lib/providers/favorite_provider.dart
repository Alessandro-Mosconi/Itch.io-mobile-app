import 'package:flutter/material.dart';
import '../helperClasses/Game.dart';

class FavoriteProvider with ChangeNotifier {
  List<Game> _favorites = [];

  List<Game> get favorites => _favorites;

  void addFavorite(Game game) {
    if (!_favorites.contains(game)) {
      _favorites.add(game);
      notifyListeners();
    }
  }

  void removeFavorite(Game game) {
    if (_favorites.contains(game)) {
      _favorites.remove(game);
      notifyListeners();
    }
  }

  bool isFavorite(Game game) {
    return _favorites.contains(game);
  }
}
