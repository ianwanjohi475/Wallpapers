import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper_model.dart';

class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();
  SupabaseClient get _sb => Supabase.instance.client;

  /// Record a download. Returns false if user is not signed in.
  Future<bool> record(String wallpaperId) async {
    final user = _sb.auth.currentUser;
    if (user == null) return false;
    await _sb.from('user_downloads').insert({
      'user_id': user.id,
      'wallpaper_id': wallpaperId,
    });
    return true;
  }

  Future<int> countMine() async {
    final user = _sb.auth.currentUser;
    if (user == null) return 0;
    final res = await _sb
        .from('user_downloads')
        .count(CountOption.exact)
        .eq('user_id', user.id);
    return res;
  }

  Future<List<WallpaperModel>> recentMine({int limit = 60}) async {
    final user = _sb.auth.currentUser;
    if (user == null) return const [];
    final rows = await _sb
        .from('user_downloads')
        .select('wallpaper:wallpapers(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows
        .cast<Map<String, dynamic>>()
        .map((r) =>
            WallpaperModel.fromJson(r['wallpaper'] as Map<String, dynamic>))
        .toList();
  }
}
