import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _notifications = [
    _NotifItem(
      icon: Icons.local_fire_department_rounded,
      iconColor: AppColors.accentOrange,
      title: 'New Pack Dropped!',
      body: 'World Cup Stadium Pack 2026 is now available — 12 new 4K wallpapers.',
      time: '2 min ago',
      isUnread: true,
    ),
    _NotifItem(
      icon: Icons.workspace_premium_rounded,
      iconColor: AppColors.accentGold,
      title: 'Premium Offer — 50% Off',
      body: 'Unlock all 800+ wallpapers for just \$0.49 today only.',
      time: '1 hr ago',
      isUnread: true,
    ),
    _NotifItem(
      icon: Icons.download_done_rounded,
      iconColor: AppColors.accentGreen,
      title: 'Download Complete',
      body: '"Galaxy Cup" has been saved to your gallery.',
      time: '3 hrs ago',
      isUnread: false,
    ),
    _NotifItem(
      icon: Icons.favorite_rounded,
      iconColor: Colors.redAccent,
      title: 'Your Favorites Synced',
      body: '47 wallpapers are backed up to cloud.',
      time: 'Yesterday',
      isUnread: false,
    ),
    _NotifItem(
      icon: Icons.sports_soccer_rounded,
      iconColor: AppColors.accentGold,
      title: 'Match Day Wallpapers',
      body: 'New wallpapers for today\'s semifinal are ready.',
      time: 'Yesterday',
      isUnread: false,
    ),
    _NotifItem(
      icon: Icons.new_releases_rounded,
      iconColor: Colors.blueAccent,
      title: 'Weekly Top 10',
      body: 'This week\'s most downloaded wallpapers are in. Check them out!',
      time: '2 days ago',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final unreadCount = _notifications.where((n) => n.isUnread).length;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'NOTIFICATIONS',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        for (final n in _notifications) {
                          n.isUnread = false;
                        }
                      });
                    },
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Unread badge
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
              ),
            ),

          // List
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off_rounded,
                            color: AppColors.textTertiary, size: 56),
                        const SizedBox(height: 16),
                        const Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We\'ll let you know when new packs drop',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 0,
                      color: AppColors.borderSubtle,
                      indent: 72,
                    ),
                    itemBuilder: (context, i) {
                      final n = _notifications[i];
                      return _NotifTile(
                        item: n,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => n.isUnread = false);
                        },
                        onDismiss: () {
                          setState(() => _notifications.removeAt(i));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  bool isUnread;

  _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifTile({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.title),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 22),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: item.isUnread
              ? AppColors.accentGold.withValues(alpha: 0.04)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: item.isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (item.isUnread)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.time,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
