import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String _sort = 'Newest';
  String _category = 'All';
  String _type = 'All';

  final _sorts = ['Newest', 'Most Downloaded', 'Most Liked', '4K Only'];
  final _categories = [
    'All', 'Teams', 'Stadiums', 'Trophies', 'Abstract', 'Legends', 'Neon', 'Dark'
  ];
  final _types = ['All', 'Free', 'Premium'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              _sectionLabel('SORT BY'),
              _chipRow(_sorts, _sort, (v) => setState(() => _sort = v)),
              _sectionLabel('CATEGORY'),
              _chipRow(_categories, _category,
                  (v) => setState(() => _category = v)),
              _sectionLabel('TYPE'),
              _chipRow(_types, _type, (v) => setState(() => _type = v)),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.bgPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: AppColors.accentGold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _chipRow(
      List<String> items, String selected, ValueChanged<String> onSelect) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          final active = selected == item;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(item);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.accentGold : AppColors.bgGlass,
                borderRadius: BorderRadius.circular(20),
                border: active
                    ? null
                    : Border.all(
                        color: AppColors.borderSubtle, width: 0.5),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: active
                      ? AppColors.bgPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
