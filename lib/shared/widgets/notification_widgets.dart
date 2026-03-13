import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/shared/services/notification_service.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Notification Bell — AppBar action icon with badge
// ═══════════════════════════════════════════════════════════════════════════════

/// A bell icon that shows the unread notification count.
/// Tap to open the [NotificationListScreen].
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  late StreamSubscription _sub;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _unread = NotificationService.instance.unreadCount;
    _sub = NotificationService.instance.stream.listen((_) {
      if (!mounted) return;
      setState(() => _unread = NotificationService.instance.unreadCount);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Thông báo',
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotificationListScreen())),
      icon: Badge(
        isLabelVisible: _unread > 0,
        label: Text(
          _unread > 9 ? '9+' : '$_unread',
          style: const TextStyle(fontSize: 10),
        ),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Notification List Screen
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late StreamSubscription _sub;
  List<AppNotification> _items = [];

  @override
  void initState() {
    super.initState();
    _items = NotificationService.instance.notifications;
    _sub = NotificationService.instance.stream.listen((list) {
      if (!mounted) return;
      setState(() => _items = list);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () => NotificationService.instance.markAllRead(),
              child: const Text('Đọc tất cả'),
            ),
          if (_items.isNotEmpty)
            IconButton(
              tooltip: 'Xoá tất cả',
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có thông báo nào',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = _items[index];
                return _NotificationTile(
                  notification: n,
                  onTap: () {
                    NotificationService.instance.markRead(n.id);
                  },
                );
              },
            ),
    );
  }

  void _confirmClear(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dlg) => AlertDialog(
        title: const Text('Xoá tất cả thông báo?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dlg);
              NotificationService.instance.clearAll();
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Single notification tile
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = _formatTime(notification.timestamp);

    return ListTile(
      onTap: onTap,
      tileColor: notification.isRead
          ? null
          : AppColors.primary.withOpacity(0.05),
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? AppColors.textHint.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.15),
        child: Icon(
          _iconForPayload(notification.payload),
          color: notification.isRead ? AppColors.textHint : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
    );
  }

  IconData _iconForPayload(String? payload) {
    if (payload == null) return Icons.notifications_outlined;
    if (payload.startsWith('enrollment')) return Icons.how_to_reg;
    if (payload.startsWith('project')) return Icons.folder_outlined;
    if (payload.startsWith('report')) return Icons.description_outlined;
    if (payload.startsWith('course')) return Icons.menu_book_outlined;
    if (payload.startsWith('semester')) return Icons.calendar_today;
    if (payload.startsWith('user')) return Icons.person_outlined;
    if (payload.startsWith('repo')) return Icons.code;
    return Icons.notifications_outlined;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }
}
