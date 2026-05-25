import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/download_service.dart';
import '../widgets/auth_required_sheet.dart';
import 'about_screen.dart';
import 'downloads_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'legal_screen.dart';
import 'login_screen.dart';
import 'premium_screen.dart';
import 'rate_app_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _newWallpapers = true;
  bool _featuredPacks = false;
  // Theme mode is managed by ThemeProvider.
  int? _downloadCount;

  @override
  void initState() {
    super.initState();
    _refreshDownloadCount();
  }

  Future<void> _refreshDownloadCount() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) {
      setState(() => _downloadCount = 0);
      return;
    }
    final c = await DownloadService.instance.countMine();
    if (mounted) setState(() => _downloadCount = c);
  }

  Future<void> _confirmLogout() async {
    HapticFeedback.lightImpact();
    final colors = AppThemeColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log out?',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'You can sign back in anytime. Your favourites stay synced.',
          style: TextStyle(
            fontFamily: 'Inter',
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthProvider>().signOut();
    await context.read<FavoritesProvider>().clearLocal();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  Future<void> _confirmResetData() async {
    HapticFeedback.mediumImpact();
    final colors = AppThemeColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.red.withValues(alpha: 0.85), size: 22),
            const SizedBox(width: 8),
            Text(
              'Reset app data?',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'This will clear your local favourites cache, search history, and saved settings. '
          'Your cloud-synced favourites stay safe. Continue?',
          style: TextStyle(
            fontFamily: 'Inter',
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final favs = context.read<FavoritesProvider>();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await favs.clearLocal();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'App data has been reset.',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: colors.bgElevated,
      ),
    );
  }

  void _push(Widget page) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;
    final auth = context.watch<AuthProvider>();
    final favCount = context.watch<FavoritesProvider>().likedCount;
    final profile = auth.profile;
    final displayName = auth.isSignedIn
        ? (profile?.name ?? profile?.email ?? 'WC Fan')
        : 'Guest Mode';
    final initials =
        auth.isSignedIn ? (profile?.initials ?? 'WC') : 'G';
    final isPremium = profile?.isPremium ?? false;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Text(
                      'PROFILE',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Profile card
              Container(
                margin: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: colors.borderSubtle, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: colors.accent, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: profile?.avatarUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: profile!.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      _initialsBadge(initials, colors),
                                )
                              : _initialsBadge(initials, colors),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isPremium) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.accentGold
                                            .withValues(alpha: 0.3),
                                        width: 0.5),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.isSignedIn
                                ? (profile?.email ?? 'Signed in')
                                : 'Browsing as guest',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (!auth.isSignedIn) {
                          showAuthRequiredSheet(context,
                              title: 'Sign in to edit profile',
                              message:
                                  'Create an account to set your name, photo, and bio.');
                          return;
                        }
                        _push(const EditProfileScreen());
                      },
                      icon: Icon(Icons.edit_rounded,
                          color: colors.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
              // Stats
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _push(const DownloadsScreen()),
                        child: _StatCard(
                            value: (_downloadCount ?? 0).toString(),
                            label: 'Downloads',
                            colors: colors),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                          value: favCount.toString(),
                          label: 'Favorites',
                          colors: colors),
                    ),
                  ],
                ),
              ),
              // Premium card
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const PremiumScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 350),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentGold.withValues(alpha: 0.12),
                        AppColors.accentOrange.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.borderGold, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: AppColors.accentGold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              r'Unlock everything for $0.99',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.accentGold, size: 14),
                    ],
                  ),
                ),
              ),
              _SectionHeader('APPEARANCE'),
              Builder(builder: (ctx) {
                final themeProv = ctx.watch<ThemeProvider>();
                return _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  label: 'Theme Mode',
                  subtitle: themeProv.label == 'System'
                      ? 'System (matches device)'
                      : themeProv.label,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ('System', ThemeMode.system),
                      ('Dark', ThemeMode.dark),
                      ('Light', ThemeMode.light),
                    ].map((entry) {
                      final label = entry.$1;
                      final mode = entry.$2;
                      final selected = themeProv.mode == mode;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ctx.read<ThemeProvider>().setMode(mode);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentGold
                                : colors.bgElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected
                                  ? AppColors.bgPrimary
                                  : colors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              _SectionHeader('NOTIFICATIONS'),
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                label: 'New Wallpapers',
                trailing: CupertinoSwitch(
                  value: _newWallpapers,
                  activeColor: AppColors.accentGold,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    setState(() => _newWallpapers = v);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.auto_awesome_rounded,
                label: 'Featured Packs',
                trailing: CupertinoSwitch(
                  value: _featuredPacks,
                  activeColor: AppColors.accentGold,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    setState(() => _featuredPacks = v);
                  },
                ),
              ),
              _SectionHeader('DOWNLOADS'),
              _SettingsTile(
                icon: Icons.high_quality_rounded,
                label: 'Image Quality',
                subtitle: '4K Ultra HD',
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              _SettingsTile(
                icon: Icons.storage_rounded,
                label: 'Clear Cache',
                subtitle: '128 MB used',
                trailing: TextButton(
                  onPressed: () => HapticFeedback.lightImpact(),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              ),
              _SectionHeader('SUPPORT'),
              _SettingsTile(
                icon: Icons.star_rounded,
                label: 'Rate App',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RateAppScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              _SettingsTile(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Share.share(
                    'Check out WC Wallpapers 2026 — 800+ epic football '
                    'wallpapers in 4K. Download it now!',
                  );
                },
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => _push(const HelpScreen()),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'About',
                onTap: () => _push(const AboutScreen()),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              _SettingsTile(
                icon: Icons.security_rounded,
                label: 'Privacy Policy',
                onTap: () => _push(LegalScreen.privacy()),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => _push(LegalScreen.terms()),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              _SectionHeader('ACCOUNT'),
              if (auth.isSignedIn)
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: 'Log Out',
                  subtitle: profile?.email,
                  onTap: _confirmLogout,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.textTertiary, size: 13),
                )
              else
                _SettingsTile(
                  icon: Icons.login_rounded,
                  label: 'Sign In / Sign Up',
                  subtitle: 'Sync favourites and download in 4K',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const LoginScreen(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration:
                            const Duration(milliseconds: 400),
                      ),
                      (_) => false,
                    );
                  },
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.textTertiary, size: 13),
                ),
              _SectionHeader('DANGER ZONE'),
              _SettingsTile(
                icon: Icons.delete_forever_rounded,
                label: 'Reset App Data',
                subtitle: 'Clears favourites, history, settings',
                iconColor: Colors.red.withValues(alpha: 0.85),
                labelColor: Colors.red.withValues(alpha: 0.85),
                onTap: _confirmResetData,
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textTertiary, size: 13),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  Center(
                    child: Text(
                      'WC WALLPAPERS 2026 · v1.0.0',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_rounded,
                          color: Colors.red.withValues(alpha: 0.7), size: 11),
                      const SizedBox(width: 4),
                      Text(
                        'Made for football fans',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300,
                          fontSize: 11,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _initialsBadge(String initials, AppThemeColors colors) {
  return Container(
    color: colors.bgElevated,
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: colors.accent,
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final AppThemeColors colors;
  const _StatCard(
      {required this.value, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderSubtle, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: colors.accentMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? colors.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: labelColor ?? colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: colors.borderSubtle,
          ),
        ),
      ],
    );
  }
}
