import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const SettingsSection({
    super.key,
    required this.title,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColors.accentGold.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i < tiles.length - 1)
                  Container(
                    height: 0.5,
                    color: AppColors.borderSubtle,
                    margin: const EdgeInsets.only(left: 56),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
