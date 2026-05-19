import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'local_storage_service.dart';
import 'onboarding_service.dart';

class NotificationService extends GetxService {
  static const _spendWarningThreshold = 0.85;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  LocalStorageService get _storage => Get.find<LocalStorageService>();

  Future<NotificationService> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    try {
      await _plugin.initialize(settings: settings);
      await _requestPermissions();
    } on MissingPluginException {
      // Widget tests and some desktop launches do not register native plugins.
    }

    ever<List<Map<String, dynamic>>>(_storage.tasks, (_) => _checkTasks());
    ever<List<Map<String, dynamic>>>(
      _storage.financeActivities,
      (_) => _checkDailySpend(),
    );
    _checkTasks();
    _checkDailySpend();

    return this;
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _checkTasks() async {
    for (final task in _storage.tasks) {
      final isUrgent = task['isUrgent'] == true || task['section'] == 'Urgent';
      final isDone = task['isDone'] == true;
      final id = task['id'] as String? ?? '';
      if (isDone || id.isEmpty) continue;

      if (_isDueToday(task)) {
        await _notifyDueTodayTask(task, id);
      }

      if (isUrgent) {
        await _notifyUrgentTask(task, id);
      }
    }
  }

  Future<void> _notifyDueTodayTask(Map<String, dynamic> task, String id) async {
    final now = DateTime.now();
    final sourceKey = 'today-task:$id:${now.year}-${now.month}-${now.day}';
    if (_storage.hasNotificationSource(sourceKey)) return;

    final title = 'Task reminder';
    final body = '${task['title'] ?? 'A task'} is due today.';
    await _storage.addAppNotification(
      title: title,
      body: body,
      type: 'task',
      sourceKey: sourceKey,
    );
    await _showSystemNotification(title: title, body: body);
  }

  Future<void> _notifyUrgentTask(Map<String, dynamic> task, String id) async {
    final sourceKey = 'urgent-task:$id';
    if (_storage.hasNotificationSource(sourceKey)) return;

    final title = 'Urgent task pending';
    final body = '${task['title'] ?? 'A task'} is still not completed.';
    await _storage.addAppNotification(
      title: title,
      body: body,
      type: 'task',
      sourceKey: sourceKey,
    );
    await _showSystemNotification(title: title, body: body);
  }

  Future<void> _checkDailySpend() async {
    final dailyBudget = Get.isRegistered<OnboardingService>()
        ? Get.find<OnboardingService>().dailyBudget.value
        : 0.0;
    if (dailyBudget <= 0) return;

    final todaySpend = _todaySpend();
    if (todaySpend / dailyBudget < _spendWarningThreshold) return;

    final now = DateTime.now();
    final sourceKey = 'daily-spend:${now.year}-${now.month}-${now.day}';
    if (_storage.hasNotificationSource(sourceKey)) return;

    final title = 'Daily spend warning';
    final body =
        'You have spent \$${todaySpend.toStringAsFixed(2)} of your \$${dailyBudget.toStringAsFixed(2)} daily budget.';
    await _storage.addAppNotification(
      title: title,
      body: body,
      type: 'finance',
      sourceKey: sourceKey,
    );
    await _showSystemNotification(title: title, body: body);
  }

  double _todaySpend() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _storage.financeActivities.fold<double>(0, (sum, activity) {
      final date = DateTime.tryParse(activity['occurredAt'] as String? ?? '');
      if (date == null || DateTime(date.year, date.month, date.day) != today) {
        return sum;
      }
      final amount = (activity['amount'] as num?)?.toDouble() ?? 0;
      return amount < 0 ? sum + amount.abs() : sum;
    });
  }

  bool _isDueToday(Map<String, dynamic> task) {
    final time = (task['time'] as String? ?? '').trim();
    if (time == 'Today') return true;

    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(time);
    if (match == null) return false;

    final month = int.tryParse(match.group(1)!);
    final day = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (month == null || day == null || year == null) return false;

    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  Future<void> _showSystemNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daydesk_alerts',
      'DayDesk Alerts',
      channelDescription: 'Task and spending alerts from DayDesk.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        notificationDetails: details,
      );
    } on MissingPluginException {
      // Keep in-app notifications working even when native plugins are absent.
    }
  }
}
