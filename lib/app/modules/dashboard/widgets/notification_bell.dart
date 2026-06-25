import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/local_storage_service.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<LocalStorageService>();

    return Obx(
      () {
        final count = storage.unreadNotificationCount;
        return IconButton(
          onPressed: () => _showNotifications(context, storage),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.primaryAccent(context),
                size: 30,
              ),
              if (count > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.urgent,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppTheme.surface(context),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showNotifications(
    BuildContext context,
    LocalStorageService storage,
  ) async {
    await Get.bottomSheet<void>(
      _NotificationsSheet(storage: storage),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    await storage.markAllNotificationsSeen();
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({required this.storage});

  final LocalStorageService storage;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.56,
      minChildSize: 0.36,
      maxChildSize: 0.82,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 56,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : const Color(0xFFDCE5F6),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Notifications',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.primaryText(context),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back<void>(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(
                  () {
                    if (storage.notifications.isEmpty) {
                      return Center(
                        child: Text(
                          'No notifications yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.secondaryText(context),
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      itemCount: storage.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = storage.notifications[index];
                        return _NotificationTile(notification: notification);
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primaryText = AppTheme.primaryText(context);
    final seen = notification['seen'] == true;
    final type = notification['type'] as String? ?? '';
    final isFinance = type == 'finance';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? (seen ? const Color(0xFF202B3D) : const Color(0xFF253454))
            : (seen ? const Color(0xFFF8F9FE) : const Color(0xFFEFF4FF)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: seen
              ? AppTheme.divider(context)
              : AppTheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isFinance
                  ? AppTheme.accent.withValues(alpha: 0.12)
                  : AppTheme.urgent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isFinance ? Icons.payments_outlined : Icons.priority_high_rounded,
              color: isFinance ? AppTheme.accent : AppTheme.urgent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] as String? ?? 'Notification',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['body'] as String? ?? '',
                  style: TextStyle(
                    color: primaryText.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!seen) ...[
            const SizedBox(width: 10),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
