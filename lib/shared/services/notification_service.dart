import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A lightweight in-app + local push notification service.
///
/// Stores recent notifications in memory and shows OS-level notifications
/// via [flutter_local_notifications].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// In-memory notification history (newest first).
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Stream that fires whenever the notification list changes.
  final _controller = StreamController<List<AppNotification>>.broadcast();
  Stream<List<AppNotification>> get stream => _controller.stream;

  bool _initialized = false;

  /// Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(settings: initSettings);
  }

  /// Push a notification (shows OS notification + stores in history).
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      payload: payload,
    );

    _notifications.insert(0, notification);
    // Keep max 50 notifications in memory.
    if (_notifications.length > 50) _notifications.removeLast();
    _controller.add(_notifications);

    // Show OS-level notification (skip on web).
    if (!kIsWeb) {
      try {
        const androidDetails = AndroidNotificationDetails(
          'edutool_channel',
          'EduTool Notifications',
          channelDescription: 'Thông báo từ EduTool',
          importance: Importance.high,
          priority: Priority.high,
        );
        const darwinDetails = DarwinNotificationDetails();
        const details = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        await _plugin.show(
          id: notification.id % 0x7FFFFFFF, // ensure valid 32-bit id
          title: title,
          body: body,
          notificationDetails: details,
          payload: payload,
        );
      } catch (_) {
        // Gracefully ignore on platforms without notification support (Windows desktop, etc.)
      }
    }
  }

  /// Mark a single notification as read.
  void markRead(int id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _controller.add(_notifications);
    }
  }

  /// Mark all as read.
  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _controller.add(_notifications);
  }

  /// Clear all notifications.
  void clearAll() {
    _notifications.clear();
    _controller.add(_notifications);
  }
}

/// A single notification item.
class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? payload;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    timestamp: timestamp,
    isRead: isRead ?? this.isRead,
    payload: payload,
  );
}
