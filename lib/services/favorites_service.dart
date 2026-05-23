import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper_model.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();
  SupabaseClient get _sb => Supabase.instance.client;

  Future<Set<String>> getLikedIds() async {
    final user = _sb.auth.currentUser;
    if (user == null) return <String>{};
    final rows = await _sb
        .from('user_favorites')
        .select('wallpaper_id')
        .eq('user_id', user.id);
    return rows
        .cast<Map<String, dynamic>>()
        .map((r) => r['wallpaper_id'] as String)
        .toSet();
  }

  Future<List<WallpaperModel>> getLikedWallpapers() async {
    final user = _sb.auth.currentUser;
    if (user == null) return const [];
    final rows = await _sb
        .from('user_favorites')
        .select('wallpaper:wallpapers(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return rows
        .cast<Map<String, dynamic>>()
        .map((r) =>
            WallpaperModel.fromJson(r['wallpaper'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> like(String wallpaperId) async {
    final user = _sb.auth.currentUser;
    if (user == null) return;
    await _sb.from('user_favorites').upsert({
      'user_id': user.id,
      'wallpaper_id': wallpaperId,
    });
  }

  Future<void> unlike(String wallpaperId) async {
    final user = _sb.auth.currentUser;
    if (user == null) return;
    await _sb
        .from('user_favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('wallpaper_id', wallpaperId);
  }
}
