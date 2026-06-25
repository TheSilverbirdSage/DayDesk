import 'notification_id.dart';

/// Discriminator for the in-app notification type.
///
/// Persisted as `type` on the in-app log row in Hive. Maps one-to-one to a
/// [NotificationCategory] and a notification channel.
enum NotificationCategory {
  taskDue,
  taskUrgent,
  financeWarning,
}

extension NotificationCategoryX on NotificationCategory {
  String get wire {
    switch (this) {
      case NotificationCategory.taskDue:
        return 'task_due';
      case NotificationCategory.taskUrgent:
        return 'task_urgent';
      case NotificationCategory.financeWarning:
        return 'finance_warning';
    }
  }

  static NotificationCategory fromWire(String? value) {
    switch (value) {
      case 'task_urgent':
        return NotificationCategory.taskUrgent;
      case 'finance_warning':
        return NotificationCategory.financeWarning;
      case 'task_due':
      default:
        return NotificationCategory.taskDue;
    }
  }
}

/// Visual priority for a notification. Drives channel selection on Android and
/// alert/sound on iOS.
enum NotificationPriority {
  low,
  defaultPriority,
  high,
  max,
}

extension NotificationPriorityX on NotificationPriority {
  String get wire {
    switch (this) {
      case NotificationPriority.low:
        return 'low';
      case NotificationPriority.defaultPriority:
        return 'default';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.max:
        return 'max';
    }
  }

  static NotificationPriority fromWire(String? value) {
    switch (value) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      case 'max':
        return NotificationPriority.max;
      case 'default':
      default:
        return NotificationPriority.defaultPriority;
    }
  }
}

/// Immutable value class consumed by [NotificationService] callers. The same
/// shape is used by the local [LocalNotificationGateway] today and the future
/// remote gateway (FCM/APNs) — see plan decision D7.
class NotificationPayload {
  const NotificationPayload({
    required this.type,
    required this.key,
    required this.title,
    required this.body,
    this.route,
    this.arguments,
    this.scheduledAt,
    this.priority = NotificationPriority.defaultPriority,
  });

  final String type;
  final String key;
  final String title;
  final String body;
  final String? route;
  final Map<String, dynamic>? arguments;
  final DateTime? scheduledAt;
  final NotificationPriority priority;

  /// Stable 31-bit positive notification id derived from [key]. Idempotent:
  /// re-issuing a payload with the same key produces the same id, so the OS
  /// replaces, not duplicates, the pending notification. See plan D3.
  int get id => payloadId(key);

  NotificationPayload copyWith({
    String? type,
    String? key,
    String? title,
    String? body,
    String? route,
    Map<String, dynamic>? arguments,
    DateTime? scheduledAt,
    NotificationPriority? priority,
  }) {
    return NotificationPayload(
      type: type ?? this.type,
      key: key ?? this.key,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      arguments: arguments ?? this.arguments,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'key': key,
      'title': title,
      'body': body,
      'route': route,
      'arguments': arguments,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'priority': priority.wire,
    };
  }

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final key = json['key'];
    if (type is! String || type.isEmpty) {
      throw ArgumentError('NotificationPayload.fromJson: missing "type".');
    }
    if (key is! String || key.isEmpty) {
      throw ArgumentError('NotificationPayload.fromJson: missing "key".');
    }
    final scheduledRaw = json['scheduledAt'];
    return NotificationPayload(
      type: type,
      key: key,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      route: json['route'] as String?,
      arguments: (json['arguments'] as Map?)?.cast<String, dynamic>(),
      scheduledAt: scheduledRaw is String
          ? DateTime.tryParse(scheduledRaw)?.toLocal()
          : null,
      priority: NotificationPriorityX.fromWire(json['priority'] as String?),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPayload &&
        other.type == type &&
        other.key == key &&
        other.title == title &&
        other.body == body &&
        other.route == route &&
        other.scheduledAt == scheduledAt &&
        other.priority == priority;
  }

  @override
  int get hashCode => Object.hash(type, key, title, body, route, scheduledAt, priority);

  @override
  String toString() => 'NotificationPayload(type: $type, key: $key, '
      'scheduledAt: $scheduledAt, priority: ${priority.wire})';
}
