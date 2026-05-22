import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper_model.dart';
import '../data/mock_data.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<String> _likedIds = {};

  bool isLiked(String id) => _likedIds.contains(id);

  void toggleLike(String id) {
    if (_likedIds.contains(id)) {
      _likedIds.remove(id);
    } else {
      _likedIds.add(id);
    }
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('liked_ids') ?? [];
    _likedIds = saved.toSet();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_ids', _likedIds.toList());
  }

  List<WallpaperModel> getLikedWallpapers() {
    return MockData.getAll().where((w) => _likedIds.contains(w.id)).toList();
  }

  int get likedCount => _likedIds.length;
}
