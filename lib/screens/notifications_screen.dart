import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    if (difference.inDays == 1) return 'yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return DateFormat('MMM d').format(timestamp);
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'welcome':
        return Icons.celebration_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      case 'download':
        return Icons.download_done_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'welcome':
        return AppColors.accentGreen;
      case 'promo':
        return AppColors.accentGold;
      case 'download':
        return AppColors.accentGreen;
      case 'favorite':
        return Colors.redAccent;
      default:
        return AppColors.accentGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final safeTop = MediaQuery.of(context).padding.top;

    return Consumer<NotificationsProvider>(
      builder: (context, notifProvider, _) {
        final notifications = notifProvider.allNotifications;
        final unreadCount = notifProvider.unreadCount;

        return Scaffold(
          backgroundColor: colors.bgPrimary,
          extendBody: true,
          body: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 16),
                decoration: BoxDecoration(
                  color: colors.bgPrimary,
                  border: Border(
                    bottom:
                        BorderSide(color: colors.borderSubtle, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: colors.textPrimary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'NOTIFICATIONS',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifProvider.markAllAsRead();
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
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_rounded,
                                color: colors.textTertiary, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "We'll let you know when new packs drop",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 0,
                          color: colors.borderSubtle,
                          indent: 72,
                        ),
                        itemBuilder: (context, i) {
                          final notif = notifications[i];
                          return _NotifTile(
                            notification: notif,
                            timeAgo: _getTimeAgo(notif.timestamp),
                            icon: _getIconForType(notif.type),
                            iconColor: _getColorForType(notif.type),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifProvider.markAsRead(notif.id);
                            },
                            onDismiss: () {
                              notifProvider.removeNotification(notif.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  final dynamic notification;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifTile({
    required this.notification,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Dismissible(
      key: ValueKey(notification.id),
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
          color: notification.isRead
              ? Colors.transparent
              : AppColors.accentGold.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                            notification.title,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: notification.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
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
                      notification.message,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: colors.textTertiary,
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
