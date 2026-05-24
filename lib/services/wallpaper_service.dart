import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../data/mock_data.dart';
import '../models/wallpaper_model.dart';

class WallpaperService {
  WallpaperService._();
  static final WallpaperService instance = WallpaperService._();

  SupabaseClient get _sb => Supabase.instance.client;

  // True only when real Supabase credentials have been supplied.
  bool get _hasRealBackend =>
      !kSupabaseUrl.contains('YOUR-PROJECT-REF') &&
      !kSupabaseAnonKey.contains('YOUR-ANON');

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
    if (!_hasRealBackend) return _featured = MockData.getFeatured();
    try {
      final rows = await _sb
          .from('wallpapers')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(limit);
      final result = _decode(rows);
      if (result.isEmpty) return _featured = MockData.getFeatured();
      return _featured = result;
    } catch (_) {
      return _featured = MockData.getFeatured();
    }
  }

  Future<List<WallpaperModel>> getNewToday({int limit = 12}) async {
    if (_newToday != null) return _newToday!;
    if (!_hasRealBackend) return _newToday = MockData.getNewToday();
    try {
      final rows = await _sb
          .from('wallpapers')
          .select()
          .eq('is_new', true)
          .order('created_at', ascending: false)
          .limit(limit);
      final result = _decode(rows);
      if (result.isEmpty) return _newToday = MockData.getNewToday();
      return _newToday = result;
    } catch (_) {
      return _newToday = MockData.getNewToday();
    }
  }

  Future<List<WallpaperModel>> getMostDownloaded({int limit = 24}) async {
    if (_mostDownloaded != null) return _mostDownloaded!;
    if (!_hasRealBackend) return _mostDownloaded = MockData.getMostDownloaded();
    try {
      final rows = await _sb
          .from('wallpapers')
          .select()
          .order('download_count', ascending: false)
          .limit(limit);
      final result = _decode(rows);
      if (result.isEmpty) return _mostDownloaded = MockData.getMostDownloaded();
      return _mostDownloaded = result;
    } catch (_) {
      return _mostDownloaded = MockData.getMostDownloaded();
    }
  }

  Future<List<WallpaperModel>> getAll({int limit = 200}) async {
    if (_all != null) return _all!;
    if (!_hasRealBackend) return _all = MockData.getBrowseAll();
    try {
      final rows = await _sb
          .from('wallpapers')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      final result = _decode(rows);
      if (result.isEmpty) return _all = MockData.getBrowseAll();
      return _all = result;
    } catch (_) {
      return _all = MockData.getBrowseAll();
    }
  }

  Future<List<WallpaperModel>> getByCategory(String category,
      {int limit = 60}) async {
    final key = category.toLowerCase();
    final cached = _byCategory[key];
    if (cached != null) return cached;
    if (key == 'all') return _byCategory[key] = await getAll(limit: limit);
    if (!_hasRealBackend) {
      return _byCategory[key] = MockData.getByCategory(category);
    }
    try {
      final rows = await _sb
          .from('wallpapers')
          .select()
          .eq('category', key)
          .order('download_count', ascending: false)
          .limit(limit);
      final result = _decode(rows);
      if (result.isEmpty) return _byCategory[key] = MockData.getByCategory(category);
      return _byCategory[key] = result;
    } catch (_) {
      return _byCategory[key] = MockData.getByCategory(category);
    }
  }

  Future<List<WallpaperModel>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    if (!_hasRealBackend) return MockData.searchAll(q);
    try {
      final rows = await _sb.rpc('search_wallpapers', params: {'q': q});
      final result = _decode(rows as List);
      if (result.isEmpty) return MockData.searchAll(q);
      return result;
    } catch (_) {
      return MockData.searchAll(q);
    }
  }

  Future<List<WallpaperModel>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    if (!_hasRealBackend) {
      return MockData.getAll().where((w) => ids.contains(w.id)).toList();
    }
    try {
      final rows = await _sb.from('wallpapers').select().inFilter('id', ids);
      final result = _decode(rows);
      if (result.isEmpty) {
        return MockData.getAll().where((w) => ids.contains(w.id)).toList();
      }
      return result;
    } catch (_) {
      return MockData.getAll().where((w) => ids.contains(w.id)).toList();
    }
  }

  Future<int> countByCategory(String category) async {
    if (!_hasRealBackend) {
      return MockData.getByCategory(category).length;
    }
    try {
      return await _sb
          .from('wallpapers')
          .count(CountOption.exact)
          .eq('category', category.toLowerCase());
    } catch (_) {
      return MockData.getByCategory(category).length;
    }
  }

  List<WallpaperModel> _decode(List<dynamic> rows) =>
      rows.cast<Map<String, dynamic>>().map(WallpaperModel.fromJson).toList();
}
