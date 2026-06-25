import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_id.dart';
import 'notification_payload.dart';

/// Contract implemented by anything that delivers notifications. The local
/// gateway uses [flutter_local_notifications] v21; a future remote gateway
/// will register FCM/APNs tokens and let the server deliver. The
/// [NotificationService] orchestrator depends only on this interface, so
/// swapping the underlying transport does not ripple to callers. See plan
/// decision D7.
abstract class NotificationGateway {
  /// One-time init. Must be safe to call multiple times.
  Future<void> init();

  /// True if [init] completed without [MissingPluginException]. Lets callers
  /// distinguish "platform not available" (tests, desktop) from "real failure".
  bool get isAvailable;

  /// Present a notification immediately.
  Future<void> show(NotificationPayload payload);

  /// Schedule a notification for delivery at [NotificationPayload.scheduledAt].
  /// If [scheduledAt] is null, behaves like [show].
  Future<void> schedule(NotificationPayload payload);

  /// Cancel a single scheduled or already-shown notification.
  Future<void> cancel(int id);

  /// Cancel all notifications with the given stable key (e.g. when the
  /// backing task is deleted or marked done). Convenience over [cancel].
  Future<void> cancelByKey(String key);

  /// IDs of notifications currently scheduled or posted by the app.
  Future<List<int>> pendingIds();

  /// Tap callback for the iOS foreground tap and Android launch-from-history
  /// flows. Returns the payload that was tapped, or null if the tap didn't
  /// reference a payload we issued.
  Stream<NotificationPayload> get taps;
}

/// Concrete gateway backed by [flutter_local_notifications] v21.
///
/// Channels (Android):
/// - `daydesk_task_due`        (high)
/// - `daydesk_task_urgent`     (max + AlarmClock category + fullScreenIntent)
/// - `daydesk_finance_warning` (default)
class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _available = false;

  final StreamController<NotificationPayload> _tapController =
      StreamController<NotificationPayload>.broadcast();

  @override
  bool get isAvailable => _available;

  @override
  Stream<NotificationPayload> get taps => _tapController.stream;

  static const _taskDueChannelId = 'daydesk_task_due';
  static const _taskUrgentChannelId = 'daydesk_task_urgent';
  static const _financeChannelId = 'daydesk_finance_warning';

  @override
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_notification_task',
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
        onDidReceiveNotificationResponse: _onTapResponse,
      );
      _available = true;
    } on MissingPluginException {
      // Widget tests + some desktop launches don't register native plugins.
      _available = false;
    } catch (error, stack) {
      _available = false;
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'daydesk.notifications',
        context: ErrorDescription('LocalNotificationGateway.init failed'),
      ));
    }
  }

  void _onTapResponse(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _tapController.add(NotificationPayload.fromJson(map));
    } catch (_) {
      // Payload wasn't ours; ignore.
    }
  }

  @override
  Future<void> show(NotificationPayload payload) async {
    if (!_available) return;
    try {
      await _plugin.show(
        id: payload.id,
        title: payload.title,
        body: payload.body,
        payload: _encodePayload(payload),
        notificationDetails: _detailsFor(payload),
      );
    } on MissingPluginException {
      _available = false;
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'daydesk.notifications',
        context: ErrorDescription('show(${payload.key}) failed'),
      ));
    }
  }

  @override
  Future<void> schedule(NotificationPayload payload) async {
    if (!_available) return;
    final scheduledAt = payload.scheduledAt;
    if (scheduledAt == null) {
      await show(payload);
      return;
    }
    try {
      await _plugin.zonedSchedule(
        id: payload.id,
        title: payload.title,
        body: payload.body,
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: _detailsFor(payload),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: _encodePayload(payload),
      );
    } on MissingPluginException {
      _available = false;
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'daydesk.notifications',
        context: ErrorDescription('schedule(${payload.key}) failed'),
      ));
    }
  }

  @override
  Future<void> cancel(int id) async {
    if (!_available) return;
    try {
      await _plugin.cancel(id: id);
    } on MissingPluginException {
      _available = false;
    }
  }

  @override
  Future<void> cancelByKey(String key) async {
    await cancel(payloadId(key));
  }

  @override
  Future<List<int>> pendingIds() async {
    if (!_available) return const <int>[];
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.map((request) => request.id).toList(growable: false);
    } on MissingPluginException {
      _available = false;
      return const <int>[];
    }
  }

  NotificationDetails _detailsFor(NotificationPayload payload) {
    final android = _androidDetailsFor(payload);
    final darwin = _darwinDetailsFor(payload);
    return NotificationDetails(android: android, iOS: darwin);
  }

  AndroidNotificationDetails _androidDetailsFor(NotificationPayload payload) {
    switch (payload.priority) {
      case NotificationPriority.max:
        return const AndroidNotificationDetails(
          _taskUrgentChannelId,
          'Urgent tasks',
          channelDescription: 'Time-critical reminders for urgent tasks.',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_notification_task',
        );
      case NotificationPriority.high:
        return const AndroidNotificationDetails(
          _taskDueChannelId,
          'Task reminders',
          channelDescription: 'Reminders for tasks due today.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_notification_task',
        );
      case NotificationPriority.low:
      case NotificationPriority.defaultPriority:
        return AndroidNotificationDetails(
          _financeChannelId,
          'Spending alerts',
          channelDescription: 'Daily spending and budget warnings.',
          importance: payload.priority == NotificationPriority.low
              ? Importance.low
              : Importance.defaultImportance,
          priority: payload.priority == NotificationPriority.low
              ? Priority.low
              : Priority.defaultPriority,
          icon: '@mipmap/ic_notification_finance',
        );
    }
  }

  DarwinNotificationDetails _darwinDetailsFor(NotificationPayload payload) {
    final isUrgent = payload.priority == NotificationPriority.max;
    final isHigh = payload.priority == NotificationPriority.high;
    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: isHigh || isUrgent,
      interruptionLevel: isUrgent
          ? InterruptionLevel.timeSensitive
          : isHigh
              ? InterruptionLevel.active
              : InterruptionLevel.passive,
    );
  }

  String _encodePayload(NotificationPayload payload) {
    return jsonEncode(payload.toJson());
  }
}
