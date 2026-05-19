import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService extends GetxService {
  static const _secureBoxName = 'daydesk_secure';
  static const _encryptionKeyName = 'daydesk_secure_box_key';
  static const _fallbackDirectoryName = '.daydesk_data';
  static const _fallbackKeyFileName = 'secure_box.key';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _onboardingProfileKey = 'onboarding_profile';
  static const _currentUserKey = 'current_user';
  static const _tasksKey = 'tasks';
  static const _financeActivitiesKey = 'finance_activities';
  static const _notificationsKey = 'notifications';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late final Box<dynamic> _secureBox;
  Directory? _fallbackDirectory;

  final tasks = <Map<String, dynamic>>[].obs;
  final financeActivities = <Map<String, dynamic>>[].obs;
  final notifications = <Map<String, dynamic>>[].obs;

  Future<LocalStorageService> init() async {
    await _initHive();
    final encryptionKey = await _loadEncryptionKey();
    _secureBox = await Hive.openBox<dynamic>(
      _secureBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    _restoreCollections();
    return this;
  }

  Future<void> _initHive() async {
    try {
      await Hive.initFlutter();
      return;
    } on MissingPluginException {
      _fallbackDirectory = await _ensureFallbackDirectory();
      Hive.init(_fallbackDirectory!.path);
    }
  }

  bool get hasCompletedOnboarding =>
      _secureBox.get(_onboardingCompletedKey, defaultValue: false) as bool;

  Future<void> setHasCompletedOnboarding(bool value) {
    return _secureBox.put(_onboardingCompletedKey, value);
  }

  Map<String, dynamic>? getOnboardingProfile() {
    final value = _secureBox.get(_onboardingProfileKey);
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<void> saveOnboardingProfile({
    required String userName,
    required String selectedCurrency,
    required int taskGoal,
    required List<String> selectedCategories,
    required double budget,
    required double savings,
  }) {
    return _secureBox.put(_onboardingProfileKey, {
      'userName': userName,
      'selectedCurrency': selectedCurrency,
      'taskGoal': taskGoal,
      'selectedCategories': selectedCategories,
      'budget': budget,
      'savings': savings,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic>? getCurrentUser() {
    final value = _secureBox.get(_currentUserKey);
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<void> saveCurrentUser({
    required String name,
    required String email,
  }) {
    return _secureBox.put(_currentUserKey, {
      'name': name,
      'email': email,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addTask({
    required String title,
    required String section,
    required String time,
    required int iconCodePoint,
    String? priority,
    String? completedText,
    bool isDone = false,
    bool isUrgent = false,
  }) {
    final task = {
      'id': _newId('task'),
      'title': title,
      'section': section,
      'time': time,
      'iconCodePoint': iconCodePoint,
      'priority': priority,
      'completedText': completedText,
      'isDone': isDone,
      'isUrgent': isUrgent,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    tasks.insert(0, task);
    return _persistTasks();
  }

  Future<void> updateTask(Map<String, dynamic> task) async {
    final id = task['id'];
    final index = tasks.indexWhere((item) => item['id'] == id);
    if (index == -1) return;

    tasks[index] = {
      ...tasks[index],
      ...task,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _persistTasks();
  }

  Future<void> addFinanceActivity({
    required String title,
    required String category,
    required double amount,
    required int iconCodePoint,
    required int iconColorValue,
    required int backgroundColorValue,
    DateTime? occurredAt,
  }) {
    final date = occurredAt ?? DateTime.now();
    final activity = {
      'id': _newId('finance'),
      'title': title,
      'category': category,
      'amount': amount,
      'time': _formatTime(date),
      'dayLabel': _formatDayLabel(date),
      'occurredAt': date.toIso8601String(),
      'iconCodePoint': iconCodePoint,
      'iconColorValue': iconColorValue,
      'backgroundColorValue': backgroundColorValue,
      'createdAt': DateTime.now().toIso8601String(),
    };
    financeActivities.insert(0, activity);
    return _persistFinanceActivities();
  }

  int get unreadNotificationCount {
    return notifications.where((item) => item['seen'] != true).length;
  }

  bool hasNotificationSource(String sourceKey) {
    return notifications.any((item) => item['sourceKey'] == sourceKey);
  }

  Future<void> addAppNotification({
    required String title,
    required String body,
    required String type,
    required String sourceKey,
  }) {
    if (hasNotificationSource(sourceKey)) return Future<void>.value();

    notifications.insert(0, {
      'id': _newId('notification'),
      'title': title,
      'body': body,
      'type': type,
      'sourceKey': sourceKey,
      'seen': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return _persistNotifications();
  }

  Future<void> markAllNotificationsSeen() async {
    for (var index = 0; index < notifications.length; index += 1) {
      notifications[index] = {
        ...notifications[index],
        'seen': true,
      };
    }
    notifications.refresh();
    await _persistNotifications();
  }

  void _restoreCollections() {
    tasks.assignAll(_readMapList(_tasksKey));
    financeActivities.assignAll(_readMapList(_financeActivitiesKey));
    notifications.assignAll(_readMapList(_notificationsKey));
  }

  List<Map<String, dynamic>> _readMapList(String key) {
    final value = _secureBox.get(key);
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _persistTasks() {
    return _secureBox.put(
        _tasksKey, tasks.map(Map<String, dynamic>.from).toList());
  }

  Future<void> _persistFinanceActivities() {
    return _secureBox.put(
      _financeActivitiesKey,
      financeActivities.map(Map<String, dynamic>.from).toList(),
    );
  }

  Future<void> _persistNotifications() {
    return _secureBox.put(
      _notificationsKey,
      notifications.map(Map<String, dynamic>.from).toList(),
    );
  }

  Future<List<int>> _loadEncryptionKey() async {
    String? existingKey;
    try {
      existingKey = await _secureStorage.read(key: _encryptionKeyName);
    } on MissingPluginException {
      return _loadFallbackEncryptionKey();
    }

    if (existingKey != null) {
      return base64Url.decode(existingKey);
    }

    final newKey = Hive.generateSecureKey();
    try {
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Url.encode(newKey),
      );
    } on MissingPluginException {
      return _saveFallbackEncryptionKey(newKey);
    }
    return newKey;
  }

  String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final prefix = switch (today.difference(target).inDays) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => _weekdayName(date.weekday),
    };
    return '$prefix, ${_monthName(date.month)} ${date.day}';
  }

  String _weekdayName(int weekday) {
    return const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][weekday - 1];
  }

  String _monthName(int month) {
    return const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  Future<List<int>> _loadFallbackEncryptionKey() async {
    final directory = _fallbackDirectory ?? await _ensureFallbackDirectory();
    final keyFile = File('${directory.path}/$_fallbackKeyFileName');
    if (await keyFile.exists()) {
      return base64Url.decode(await keyFile.readAsString());
    }

    return _saveFallbackEncryptionKey(Hive.generateSecureKey());
  }

  Future<List<int>> _saveFallbackEncryptionKey(List<int> key) async {
    final directory = _fallbackDirectory ?? await _ensureFallbackDirectory();
    final keyFile = File('${directory.path}/$_fallbackKeyFileName');
    await keyFile.writeAsString(base64Url.encode(key), flush: true);
    return key;
  }

  Future<Directory> _ensureFallbackDirectory() async {
    final candidates = <String?>[
      Platform.environment['HOME'],
      Platform.environment['TMPDIR'],
      Platform.environment['TEMP'],
      Platform.environment['TMP'],
      Directory.systemTemp.path,
      Directory.current.path,
    ].where(_isUsableBasePath);

    for (final basePath in candidates) {
      final directory = Directory('$basePath/$_fallbackDirectoryName');
      if (await _canUseDirectory(directory)) {
        _fallbackDirectory = directory;
        return directory;
      }
    }

    throw FileSystemException(
      'No writable fallback directory found for local storage.',
      _fallbackDirectoryName,
    );
  }

  bool _isUsableBasePath(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    final normalized = path.trim();
    return normalized != '/' && normalized != r'\';
  }

  Future<bool> _canUseDirectory(Directory directory) async {
    try {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final probeFile = File('${directory.path}/.write_test');
      await probeFile.writeAsString('ok', flush: true);
      await probeFile.delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }
}
