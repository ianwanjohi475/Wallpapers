import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/nav_item.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BrowseScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  final List<_NavData> _navItems = const [
    _NavData(icon: Icons.home_rounded, label: 'Home'),
    _NavData(icon: Icons.grid_view_rounded, label: 'Browse'),
    _NavData(icon: Icons.search_rounded, label: 'Search'),
    _NavData(icon: Icons.favorite_rounded, label: 'Saved'),
    _NavData(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // padding.bottom is non-zero only on devices that still report a
    // gesture inset inside the app frame (older Android edge-to-edge,
    // iOS home indicator). On modern Android with a solid system nav
    // it's 0 because the bar lives in its own frame.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 64 + bottomInset,
                  decoration: const BoxDecoration(
                    color: Color(0xEB08080F),
                    border: Border(
                      top: BorderSide(
                        color: Color(0x0FFFFFFF),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        _navItems.length,
                        (i) => NavItem(
                          icon: _navItems[i].icon,
                          label: _navItems[i].label,
                          selected: _selectedIndex == i,
                          onTap: () => setState(() => _selectedIndex = i),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final String label;
  const _NavData({required this.icon, required this.label});
}
