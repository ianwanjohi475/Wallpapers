class WallpaperModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? thumbUrl;
  final String category;
  final bool isPremium;
  final bool isFeatured;
  final bool isNew;
  final int downloadCount;
  final int likeCount;
  final String resolution;
  final List<String> tags;
  final String? slug;

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.thumbUrl,
    required this.category,
    required this.isPremium,
    required this.isFeatured,
    this.isNew = false,
    required this.downloadCount,
    required this.likeCount,
    required this.resolution,
    this.tags = const [],
    this.slug,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> j) {
    return WallpaperModel(
      id: j['id'] as String,
      slug: j['slug'] as String?,
      title: (j['title'] ?? '') as String,
      imageUrl: (j['image_url'] ?? '') as String,
      thumbUrl: j['thumb_url'] as String?,
      category: (j['category'] ?? '') as String,
      isPremium: (j['is_premium'] ?? false) as bool,
      isFeatured: (j['is_featured'] ?? false) as bool,
      isNew: (j['is_new'] ?? false) as bool,
      downloadCount: (j['download_count'] ?? 0) as int,
      likeCount: (j['like_count'] ?? 0) as int,
      resolution: (j['resolution'] ?? '4K') as String,
      tags: (j['tags'] as List?)?.cast<String>() ?? const [],
    );
  }

  // Grid-optimised image URL (smaller, faster). Falls back to imageUrl.
  String get gridUrl => thumbUrl ?? _resized(imageUrl, 600);

  // Detail/hero URL — medium resolution for snappy first paint.
  String get previewUrl => _resized(imageUrl, 1280);

  static String _resized(String url, int w) {
    if (url.contains('images.unsplash.com')) {
      // Unsplash dynamic CDN — swap any width param.
      final hasQ = url.contains('?');
      final base = hasQ ? url.split('?').first : url;
      return '$base?auto=format&fit=crop&w=$w&q=80';
    }
    return url;
  }
}
