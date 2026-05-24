import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

/// Manages in-app notifications — persisted locally in SharedPreferences.
class NotificationsProvider extends ChangeNotifier {
  static const _kNotificationsKey = 'notifications';
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications.where((n) => !n.isRead));

  List<NotificationModel> get allNotifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kNotificationsKey) ?? [];
    _notifications = saved
        .map((json) => NotificationModel.fromJson(json))
        .toList();
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  /// Add a new notification and persist it.
  Future<void> addNotification({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    final notification = NotificationModel(
      id: const Uuid().v4(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );
    _notifications.insert(0, notification);
    await _persistLocal();
    notifyListeners();
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persistLocal();
      notifyListeners();
    }
  }

  /// Remove a notification.
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _persistLocal();
    notifyListeners();
  }

  /// Mark all as read.
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _persistLocal();
    notifyListeners();
  }

  /// Clear all notifications.
  Future<void> clearAll() async {
    _notifications.clear();
    await _persistLocal();
    notifyListeners();
  }

  /// Add a welcome notification (typically called on successful signup).
  Future<void> addWelcomeNotification() async {
    await addNotification(
      title: 'Welcome to WC Wallpapers!',
      message: 'Your account has been created. Explore our premium collection of wallpapers.',
      type: 'welcome',
    );
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _notifications.map((n) => n.toJson()).toList();
    await prefs.setStringList(_kNotificationsKey, json);
  }
}
