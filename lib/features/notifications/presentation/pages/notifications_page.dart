import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/core/services/notifications/notification_service.dart';

/// Maps a notification's [NotificationRecord.type] to an icon.
/// Add a case here whenever a new notification type is introduced.
IconData _iconForType(String type) {
  switch (type) {
    case 'welcome':
      return Icons.celebration_outlined;
    case 'order':
      return Icons.check_circle_outline_rounded;
    case 'message':
      return Icons.chat_bubble_outline_rounded;
    case 'price_drop':
      return Icons.trending_down_rounded;
    case 'listing_approved':
      return Icons.verified_outlined;
    case 'profile_updated':
      return Icons.account_circle_outlined;
    default:
      return Icons.notifications_none_rounded;
  }
}

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final grouped = _groupByDate(notifications);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                for (final group in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                    child: Text(
                      group.key,
                      style: TextStyle(
                        color: context.textTertiary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < group.value.length; i++)
                          _NotificationTile(
                            item: group.value[i],
                            isLast: i == group.value.length - 1,
                            onTap: () => ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(group.value[i].id),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  /// Buckets notifications into "Today", "Yesterday", and "Earlier".
  Map<String, List<NotificationRecord>> _groupByDate(
      List<NotificationRecord> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final map = <String, List<NotificationRecord>>{
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final item in items) {
      final day = DateTime(item.time.year, item.time.month, item.time.day);
      if (day == today) {
        map['Today']!.add(item);
      } else if (day == yesterday) {
        map['Yesterday']!.add(item);
      } else {
        map['Earlier']!.add(item);
      }
    }

    map.removeWhere((key, value) => value.isEmpty);
    return map;
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationRecord item;
  final bool isLast;
  final VoidCallback? onTap;
  const _NotificationTile({required this.item, required this.isLast, this.onTap});

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconForType(item.type), color: accent, size: 20),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
              fontSize: 14,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.textSecondary, fontSize: 12.5),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 2),
              Text(
                _timeAgo(item.time),
                style: TextStyle(color: context.textTertiary, fontSize: 10.5),
              ),
              const SizedBox(height: 6),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, indent: 66),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: context.textTertiary),
          const SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}