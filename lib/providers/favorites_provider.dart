import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper_model.dart';
import '../services/favorites_service.dart';

/// Tracks liked wallpaper IDs.
///
/// - Guests:    persisted in SharedPreferences only.
/// - Signed in: persisted in Supabase (user_favorites) and mirrored locally.
class FavoritesProvider extends ChangeNotifier {
  static const _kLocalKey = 'liked_ids';

  Set<String> _likedIds = {};
  List<WallpaperModel> _likedCache = [];

  bool isLiked(String id) => _likedIds.contains(id);
  int get likedCount => _likedIds.length;
  Set<String> get likedIds => Set.unmodifiable(_likedIds);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kLocalKey) ?? [];
    _likedIds = saved.toSet();
    notifyListeners();
  }

  /// Pulls server-side favorites for the signed-in user and merges them
  /// with any pending local ones (so a guest who signs in keeps their likes).
  Future<void> syncWithServer() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final remote = await FavoritesService.instance.getLikedIds();
    final localOnly = _likedIds.difference(remote);
    for (final id in localOnly) {
      await FavoritesService.instance.like(id);
    }
    _likedIds = remote.union(_likedIds);
    _likedCache = await FavoritesService.instance.getLikedWallpapers();
    await _persistLocal();
    notifyListeners();
  }

  Future<void> toggleLike(String id) async {
    final wasLiked = _likedIds.contains(id);
    if (wasLiked) {
      _likedIds.remove(id);
      _likedCache.removeWhere((w) => w.id == id);
    } else {
      _likedIds.add(id);
    }
    notifyListeners();
    await _persistLocal();
    final signedIn = Supabase.instance.client.auth.currentUser != null;
    if (signedIn) {
      try {
        if (wasLiked) {
          await FavoritesService.instance.unlike(id);
        } else {
          await FavoritesService.instance.like(id);
          // Refresh cached wallpapers list so favourites screen updates.
          _likedCache = await FavoritesService.instance.getLikedWallpapers();
          notifyListeners();
        }
      } catch (_) {
        // Best-effort; local state is the source of truth for UI snap.
      }
    }
  }

  /// Used by FavoritesScreen — returns hydrated wallpaper models if the user
  /// is signed in (server-side join), otherwise falls back to nothing
  /// (a guest can like locally but can't see the full image library yet).
  List<WallpaperModel> getLikedWallpapers() => List.unmodifiable(_likedCache);

  /// Allows other screens (Home, Browse) to feed in their already-loaded
  /// wallpapers so favourites can resolve titles for guests.
  void hydrateFromList(Iterable<WallpaperModel> pool) {
    final ids = _likedIds;
    _likedCache = pool.where((w) => ids.contains(w.id)).toList();
  }

  Future<void> clearLocal() async {
    _likedIds.clear();
    _likedCache.clear();
    await _persistLocal();
    notifyListeners();
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kLocalKey, _likedIds.toList());
  }
}
