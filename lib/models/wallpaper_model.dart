class WallpaperModel {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final bool isPremium;
  final bool isFeatured;
  final int downloadCount;
  final int likeCount;
  final String resolution;

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.isPremium,
    required this.isFeatured,
    required this.downloadCount,
    required this.likeCount,
    required this.resolution,
  });
}
