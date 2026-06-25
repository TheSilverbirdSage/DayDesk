import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'local_storage_service.dart';
import 'notification_id.dart';
import 'onboarding_service.dart';

class NotificationService extends GetxService with WidgetsBindingObserver {
  static const _spendWarningThreshold = 0.85;
  static const _expiryReminderHour = 21;
  static const _expiryReminderMinute = 0;
  static const _extendTaskPayloadPrefix = 'extend-task';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  LocalStorageService get _storage => Get.find<LocalStorageService>();

  final _scheduledTaskKeys = <String>{};
  final _expiryReminderKeys = <String>{};

  Timer? _timer;
  bool _notificationsAvailable = false;

  Future<NotificationService> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );
      await _requestPermissions();
      _notificationsAvailable = true;
      await _handleLaunchNotification();
    } on MissingPluginException {
      // Widget tests and some desktop launches do not register native plugins.
      _notificationsAvailable = false;
    } catch (error, stack) {
      _notificationsAvailable = false;
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'daydesk.notifications',
        context: ErrorDescription('NotificationService.init failed'),
      ));
    }

    ever<List<Map<String, dynamic>>>(_storage.tasks, (_) {
      _checkTasks();
      unawaited(_deleteExpiredTasks());
      unawaited(_syncScheduledTaskNotifications());
    });
    ever<List<Map<String, dynamic>>>(
      _storage.financeActivities,
      (_) => _checkDailySpend(),
    );
    unawaited(_deleteExpiredTasks());
    _checkTasks();
    _checkDailySpend();
    unawaited(_syncScheduledTaskNotifications());
    unawaited(_checkScheduledTasks());

    // Check for scheduled tasks every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      unawaited(_deleteExpiredTasks());
      unawaited(_checkScheduledTasks());
    });

    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_deleteExpiredTasks());
    unawaited(_syncScheduledTaskNotifications());
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _configureLocalTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } on MissingPluginException {
      // Tests and non-mobile targets can use the package default timezone.
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'daydesk.notifications',
        context: ErrorDescription('Timezone setup failed'),
      ));
    }
  }

  Future<void> _handleLaunchNotification() async {
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp != true) return;
    await _handleNotificationPayload(
      launchDetails?.notificationResponse?.payload,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    unawaited(_handleNotificationPayload(response.payload));
  }

  Future<void> _handleNotificationPayload(String? payload) async {
    if (payload == null || payload.isEmpty) return;
    final parts = payload.split(':');
    if (parts.length < 2 || parts.first != _extendTaskPayloadPrefix) return;

    await _moveTaskToNextDay(parts[1]);
    await _deleteExpiredTasks();
    await _syncScheduledTaskNotifications();
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

  Future<void> _checkScheduledTasks() async {
    final now = DateTime.now();
    for (final task in _storage.tasks) {
      final isDone = task['isDone'] == true;
      final scheduledAtStr = task['scheduledAt'] as String?;
      final id = task['id'] as String? ?? '';

      if (isDone || id.isEmpty || scheduledAtStr == null) continue;

      final scheduledAt = DateTime.tryParse(scheduledAtStr);
      if (scheduledAt == null) continue;

      // Check if the scheduled time is within the next minute
      final difference = scheduledAt.difference(now);
      if (difference.isNegative) {
        // Time has passed, check if we should notify about missed task
        final oneDayAgo = now.subtract(const Duration(days: 1));
        if (scheduledAt.isAfter(oneDayAgo)) {
          final sourceKey =
              'missed-task:$id:${scheduledAt.millisecondsSinceEpoch ~/ 60000}';
          if (_storage.hasNotificationSource(sourceKey)) continue;

          final body = _scheduledTaskBody(task, scheduledAt);
          await _notifyMissedTask(task, id, scheduledAt);
          await _storage.addAppNotification(
            title: 'You missed a task',
            body: body,
            type: 'task',
            sourceKey: sourceKey,
          );
        }
        continue;
      }

      // Future scheduled notifications are owned by the OS so they still fire
      // when the app is closed. This timer only handles missed-task logging.
    }
  }

  Future<void> _syncScheduledTaskNotifications() async {
    if (!_notificationsAvailable) return;

    final now = DateTime.now();
    final desiredScheduledKeys = <String>{};
    final desiredExpiryKeys = <String>{};

    for (final task in _storage.tasks) {
      final isDone = task['isDone'] == true;
      final id = task['id'] as String? ?? '';
      if (id.isEmpty) continue;

      if (isDone) {
        await _cancelTaskNotifications(task);
        continue;
      }

      final scheduledAt = _taskScheduledAt(task);
      if (scheduledAt != null && scheduledAt.isAfter(now)) {
        final key = _scheduledTaskKey(id, scheduledAt);
        desiredScheduledKeys.add(key);
        await _scheduleTaskNotification(task, key, scheduledAt);
      }

      final dueDay = _taskDueDay(task);
      if (dueDay != null && !dueDay.isBefore(_today())) {
        final key = _expiryReminderKey(id, dueDay);
        final reminderAt = _expiryReminderTime(dueDay, now);
        if (reminderAt != null) {
          desiredExpiryKeys.add(key);
          await _scheduleExpiryReminder(task, key, reminderAt);
        }
      }
    }

    for (final staleKey
        in _scheduledTaskKeys.difference(desiredScheduledKeys)) {
      await _plugin.cancel(id: payloadId(staleKey));
    }
    for (final staleKey in _expiryReminderKeys.difference(desiredExpiryKeys)) {
      await _plugin.cancel(id: payloadId(staleKey));
    }

    _scheduledTaskKeys
      ..clear()
      ..addAll(desiredScheduledKeys);
    _expiryReminderKeys
      ..clear()
      ..addAll(desiredExpiryKeys);
  }

  Future<void> _scheduleTaskNotification(
    Map<String, dynamic> task,
    String key,
    DateTime scheduledAt,
  ) async {
    final title = 'Time to do your task!';
    final body = _scheduledTaskBody(task, scheduledAt);

    const androidDetails = AndroidNotificationDetails(
      'daydesk_task_due',
      'Task reminders',
      channelDescription: 'Scheduled task reminders from DayDesk.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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
      await _plugin.zonedSchedule(
        id: payloadId(key),
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: key,
      );
    } on MissingPluginException {
      _notificationsAvailable = false;
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'daydesk.notifications',
        context: ErrorDescription('Scheduling task notification failed'),
      ));
    }
  }

  Future<void> _scheduleExpiryReminder(
    Map<String, dynamic> task,
    String key,
    DateTime reminderAt,
  ) async {
    final taskTitle = (task['title'] as String?)?.trim();
    final displayTitle =
        taskTitle == null || taskTitle.isEmpty ? 'this task' : taskTitle;
    final id = task['id'] as String? ?? '';
    if (id.isEmpty) return;

    const title = 'Task expires soon';
    final body = "Couldn't achieve $displayTitle today? Set for another day.";

    const androidDetails = AndroidNotificationDetails(
      'daydesk_task_expiry',
      'Task expiry reminders',
      channelDescription: 'Reminders before daily tasks expire.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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
      await _plugin.zonedSchedule(
        id: payloadId(key),
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '$_extendTaskPayloadPrefix:$id',
      );
    } on MissingPluginException {
      _notificationsAvailable = false;
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'daydesk.notifications',
        context: ErrorDescription('Scheduling task expiry reminder failed'),
      ));
    }
  }

  Future<void> _cancelTaskNotifications(Map<String, dynamic> task) async {
    final id = task['id'] as String? ?? '';
    if (id.isEmpty) return;

    final scheduledAt = _taskScheduledAt(task);
    if (scheduledAt != null) {
      await _plugin.cancel(id: payloadId(_scheduledTaskKey(id, scheduledAt)));
    }

    final dueDay = _taskDueDay(task);
    if (dueDay != null) {
      await _plugin.cancel(id: payloadId(_expiryReminderKey(id, dueDay)));
    }
  }

  Future<void> _deleteExpiredTasks() async {
    final today = _today();
    final expiredIds = <String>[];
    final consistentTasksToReset = <Map<String, dynamic>>[];

    for (final task in _storage.tasks) {
      final id = task['id'] as String? ?? '';
      if (id.isEmpty) continue;
      final dueDay = _taskDueDay(task);
      if (dueDay == null || !dueDay.isBefore(today)) continue;
      await _cancelTaskNotifications(task);
      if (_isConsistentTask(task)) {
        consistentTasksToReset.add(task);
        continue;
      }
      expiredIds.add(id);
    }

    for (final task in consistentTasksToReset) {
      await _resetConsistentTaskForToday(task, today);
    }

    for (final id in expiredIds) {
      await _storage.deleteTask(id);
    }
  }

  Future<void> _resetConsistentTaskForToday(
    Map<String, dynamic> task,
    DateTime today,
  ) async {
    final scheduledAt = _taskScheduledAt(task);
    final nextScheduledAt = scheduledAt == null
        ? null
        : DateTime(
            today.year,
            today.month,
            today.day,
            scheduledAt.hour,
            scheduledAt.minute,
          );

    await _storage.updateTask({
      ...task,
      'time': 'Today',
      'dueDate': today.toIso8601String(),
      'scheduledAt': nextScheduledAt?.toIso8601String(),
      'isDone': false,
      'completedText': null,
      'isConsistent': true,
    });
  }

  Future<void> _moveTaskToNextDay(String id) async {
    final task = _storage.tasks.firstWhereOrNull((item) => item['id'] == id);
    if (task == null) return;

    final dueDay = _taskDueDay(task) ?? _today();
    var nextDay = dueDay.add(const Duration(days: 1));
    final today = _today();
    if (nextDay.isBefore(today)) nextDay = today;

    final scheduledAt = _taskScheduledAt(task);
    final nextScheduledAt = scheduledAt == null
        ? null
        : DateTime(
            nextDay.year,
            nextDay.month,
            nextDay.day,
            scheduledAt.hour,
            scheduledAt.minute,
          );

    await _storage.updateTask({
      ...task,
      'time': _formatDateLabel(nextDay),
      'dueDate': nextDay.toIso8601String(),
      'scheduledAt': nextScheduledAt?.toIso8601String(),
      'isDone': false,
      'completedText': null,
    });
  }

  Future<void> _notifyMissedTask(
      Map<String, dynamic> task, String id, DateTime scheduledAt) async {
    final title = 'You missed a task';
    final body = _scheduledTaskBody(task, scheduledAt);
    await _showSystemNotification(title: title, body: body);
  }

  String _scheduledTaskBody(Map<String, dynamic> task, DateTime scheduledAt) {
    final taskTitle = (task['title'] as String?)?.trim();
    final displayTitle =
        taskTitle == null || taskTitle.isEmpty ? 'A task' : taskTitle;
    final time = _formatTime(scheduledAt);
    final day = _formatScheduledDay(scheduledAt);
    return '$displayTitle was scheduled for $time $day.';
  }

  String _scheduledTaskKey(String id, DateTime scheduledAt) {
    return 'scheduled-task:$id:${scheduledAt.millisecondsSinceEpoch ~/ 60000}';
  }

  String _expiryReminderKey(String id, DateTime dueDay) {
    return 'expiry-task:$id:${dueDay.year}-${dueDay.month}-${dueDay.day}';
  }

  DateTime? _taskScheduledAt(Map<String, dynamic> task) {
    final scheduledAtStr = task['scheduledAt'] as String?;
    if (scheduledAtStr == null || scheduledAtStr.isEmpty) return null;
    return DateTime.tryParse(scheduledAtStr);
  }

  DateTime? _taskDueDay(Map<String, dynamic> task) {
    final dueDate = DateTime.tryParse(task['dueDate'] as String? ?? '');
    if (dueDate != null) {
      return DateTime(dueDate.year, dueDate.month, dueDate.day);
    }

    final scheduledAt = _taskScheduledAt(task);
    if (scheduledAt != null) {
      return DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
    }

    final time = (task['time'] as String? ?? '').trim();
    if (time == 'Today') {
      final createdAt = DateTime.tryParse(task['createdAt'] as String? ?? '');
      final base = createdAt ?? DateTime.now();
      return DateTime(base.year, base.month, base.day);
    }

    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(time);
    if (match == null) return null;

    final month = int.tryParse(match.group(1)!);
    final day = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }

  bool _isConsistentTask(Map<String, dynamic> task) {
    return task['isConsistent'] == true || task['section'] == 'Consistent';
  }

  DateTime? _expiryReminderTime(DateTime dueDay, DateTime now) {
    final endOfDay = DateTime(dueDay.year, dueDay.month, dueDay.day, 23, 59);
    if (!now.isBefore(endOfDay)) return null;

    final target = DateTime(
      dueDay.year,
      dueDay.month,
      dueDay.day,
      _expiryReminderHour,
      _expiryReminderMinute,
    );
    if (target.isAfter(now)) return target;

    final soon = now.add(const Duration(minutes: 1));
    return soon.isBefore(endOfDay) ? soon : null;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _formatDateLabel(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  String _formatScheduledDay(DateTime scheduledAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDay =
        DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);

    if (scheduledDay == today) return 'today';
    if (scheduledDay == today.subtract(const Duration(days: 1))) {
      return 'yesterday';
    }

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return 'on ${weekdays[scheduledAt.weekday - 1]}';
  }

  bool _isDueToday(Map<String, dynamic> task) {
    final dueDay = _taskDueDay(task);
    if (dueDay == null) return false;
    return dueDay == _today();
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
