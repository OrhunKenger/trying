import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = ref.watch(notificationsProvider);
    final unread = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () {
                final updated = notifications.map((n) => NotificationModel(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  type: n.type,
                  isRead: true,
                  createdAt: n.createdAt,
                )).toList();
                ref.read(notificationsProvider.notifier).state = updated;
              },
              child: const Text('Tümünü Okundu İşaretle'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 100,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  const Text(
                    'Bildirim Yok',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _NotificationCard(
                  notification: notifications[index],
                  isDark: isDark,
                  onTap: () {
                    final updated = notifications.asMap().map((i, n) {
                      if (i == index) {
                        return MapEntry(i, NotificationModel(
                          id: n.id,
                          title: n.title,
                          body: n.body,
                          type: n.type,
                          isRead: true,
                          createdAt: n.createdAt,
                        ));
                      }
                      return MapEntry(i, n);
                    }).values.toList();
                    ref.read(notificationsProvider.notifier).state = updated;
                  },
                ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms);
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : config.$1.withOpacity(0.4),
            width: notification.isRead ? 0.5 : 1.5,
          ),
          boxShadow: notification.isRead
              ? null
              : [
                  BoxShadow(
                    color: config.$1.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: config.$1.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(config.$2, color: config.$1, size: 22),
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
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: config.$1,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.createdAt,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, IconData) _getConfig(NotificationType type) {
    switch (type) {
      case NotificationType.favorited:
        return (AppColors.primary, Icons.favorite);
      case NotificationType.boostReady:
        return (AppColors.gold, Icons.bolt);
      case NotificationType.renewal:
        return (AppColors.warning, Icons.refresh);
      case NotificationType.approved:
        return (AppColors.success, Icons.check_circle);
      case NotificationType.rejected:
        return (AppColors.error, Icons.cancel);
    }
  }
}
