import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper_model.dart';

class WallpaperService {
  WallpaperService._();
  static final WallpaperService instance = WallpaperService._();

  SupabaseClient get _sb => Supabase.instance.client;

  // In-memory caches so a tab swipe doesn't re-hit the network.
  final Map<String, List<WallpaperModel>> _byCategory = {};
  List<WallpaperModel>? _featured;
  List<WallpaperModel>? _newToday;
  List<WallpaperModel>? _mostDownloaded;
  List<WallpaperModel>? _all;

  void clearCache() {
    _byCategory.clear();
    _featured = null;
    _newToday = null;
    _mostDownloaded = null;
    _all = null;
  }

  Future<List<WallpaperModel>> getFeatured({int limit = 8}) async {
    if (_featured != null) return _featured!;
    final rows = await _sb
        .from('wallpapers')
        .select()
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return _featured = _decode(rows);
  }

  Future<List<WallpaperModel>> getNewToday({int limit = 12}) async {
    if (_newToday != null) return _newToday!;
    final rows = await _sb
        .from('wallpapers')
        .select()
        .eq('is_new', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return _newToday = _decode(rows);
  }

  Future<List<WallpaperModel>> getMostDownloaded({int limit = 24}) async {
    if (_mostDownloaded != null) return _mostDownloaded!;
    final rows = await _sb
        .from('wallpapers')
        .select()
        .order('download_count', ascending: false)
        .limit(limit);
    return _mostDownloaded = _decode(rows);
  }

  Future<List<WallpaperModel>> getAll({int limit = 200}) async {
    if (_all != null) return _all!;
    final rows = await _sb
        .from('wallpapers')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return _all = _decode(rows);
  }

  Future<List<WallpaperModel>> getByCategory(String category,
      {int limit = 60}) async {
    final key = category.toLowerCase();
    final cached = _byCategory[key];
    if (cached != null) return cached;
    if (key == 'all') return _byCategory[key] = await getAll(limit: limit);
    final rows = await _sb
        .from('wallpapers')
        .select()
        .eq('category', key)
        .order('download_count', ascending: false)
        .limit(limit);
    return _byCategory[key] = _decode(rows);
  }

  Future<List<WallpaperModel>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final rows = await _sb.rpc('search_wallpapers', params: {'q': q});
    return _decode(rows as List);
  }

  Future<List<WallpaperModel>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows =
        await _sb.from('wallpapers').select().inFilter('id', ids);
    return _decode(rows);
  }

  Future<int> countByCategory(String category) async {
    final res = await _sb
        .from('wallpapers')
        .count(CountOption.exact)
        .eq('category', category.toLowerCase());
    return res;
  }

  List<WallpaperModel> _decode(List<dynamic> rows) =>
      rows.cast<Map<String, dynamic>>().map(WallpaperModel.fromJson).toList();
}
