import 'package:flutter/foundation.dart';
import '../models/wallpaper_model.dart';
import '../data/mock_data.dart';

class WallpaperProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<WallpaperModel> get filteredWallpapers {
    var all = MockData.getBrowseAll();
    if (_selectedCategory != 'All') {
      all = all.where((w) => w.category == _selectedCategory.toLowerCase()).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      all = all.where((w) =>
        w.title.toLowerCase().contains(q) ||
        w.category.toLowerCase().contains(q)).toList();
    }
    return all;
  }

  List<WallpaperModel> get searchResults {
    if (_searchQuery.isEmpty) return MockData.getSearchResults();
    final q = _searchQuery.toLowerCase();
    return MockData.getAll().where((w) =>
      w.title.toLowerCase().contains(q) ||
      w.category.toLowerCase().contains(q)).toList();
  }
}
