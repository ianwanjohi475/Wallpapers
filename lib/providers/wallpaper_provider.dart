import 'package:flutter/foundation.dart';
import '../models/wallpaper_model.dart';
import '../services/wallpaper_service.dart';

/// Lightweight UI state for filter/search across screens.
/// Heavy lifting (network) lives in [WallpaperService].
class WallpaperProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearch(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    notifyListeners();
  }

  Future<List<WallpaperModel>> fetchForBrowse() async {
    if (_selectedCategory == 'All') {
      return WallpaperService.instance.getAll();
    }
    return WallpaperService.instance.getByCategory(_selectedCategory);
  }

  Future<List<WallpaperModel>> fetchSearch() async {
    if (_searchQuery.trim().isEmpty) return const [];
    return WallpaperService.instance.search(_searchQuery);
  }
}
