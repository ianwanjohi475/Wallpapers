import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../models/wallpaper_model.dart';
import 'wallpaper_grid_card.dart';

/// A multi-column masonry that adapts its column count to the device
/// width (2 on phones, up to 5 on large tablets). It lays itself out
/// with a plain Row of Columns so it drops cleanly into any scrollable
/// — SingleChildScrollView, SliverToBoxAdapter, etc.
class ResponsiveMasonry extends StatelessWidget {
  final List<WallpaperModel> items;
  final bool alwaysLiked;
  final double spacing;

  const ResponsiveMasonry({
    super.key,
    required this.items,
    this.alwaysLiked = false,
    this.spacing = 12,
  });

  static const _heights = <double>[
    240, 180, 260, 200, 220, 170, 250, 190,
  ];

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.gridColumns(context);
    final columns = List.generate(cols, (_) => <Widget>[]);

    for (var i = 0; i < items.length; i++) {
      columns[i % cols].add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: WallpaperGridCard(
            wallpaper: items[i],
            height: _heights[i % _heights.length],
            alwaysLiked: alwaysLiked,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < cols; c++) ...[
          if (c > 0) SizedBox(width: spacing),
          Expanded(
            child: Column(
              children: [
                // Stagger every other column for the masonry effect.
                if (c.isOdd) const SizedBox(height: 36),
                ...columns[c],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
