import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/local_storage_service.dart';
import '../../../data/services/onboarding_service.dart';

class TaskListItem {
  TaskListItem({
    required this.id,
    required this.title,
    required this.section,
    required this.time,
    required this.icon,
    this.priority,
    this.completedText,
    this.isDone = false,
    this.isUrgent = false,
  });

  final String id;
  final String title;
  final String section;
  final String time;
  final IconData icon;
  final String? priority;
  final String? completedText;
  bool isDone;
  final bool isUrgent;

  Map<String, dynamic> toStorageMap() {
    return {
      'id': id,
      'title': title,
      'section': section,
      'time': time,
      'iconCodePoint': icon.codePoint,
      'priority': priority,
      'completedText': completedText,
      'isDone': isDone,
      'isUrgent': isUrgent,
    };
  }

  factory TaskListItem.fromStorageMap(Map<String, dynamic> map) {
    return TaskListItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled task',
      section: map['section'] as String? ?? 'Work',
      time: map['time'] as String? ?? 'Today',
      icon: IconData(
        map['iconCodePoint'] as int? ?? Icons.event_rounded.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      priority: map['priority'] as String?,
      completedText: map['completedText'] as String?,
      isDone: map['isDone'] as bool? ?? false,
      isUrgent: map['isUrgent'] as bool? ?? false,
    );
  }
}

class TaskSection {
  const TaskSection({
    required this.title,
    required this.countColor,
    required this.tasks,
  });

  final String title;
  final Color countColor;
  final List<TaskListItem> tasks;

  String get countLabel =>
      '${tasks.length} ${tasks.length == 1 ? 'TASK' : 'TASKS'}';
}

class TasksController extends GetxController {
  final searchController = TextEditingController();
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  final tasks = <TaskListItem>[].obs;

  LocalStorageService get _storage => Get.find<LocalStorageService>();

  List<String> get categories {
    final onboardingCategories = Get.isRegistered<OnboardingService>()
        ? Get.find<OnboardingService>().categories
        : const <String>[];
    final taskSections = tasks.map((task) => task.section);
    final values = <String>{
      'All',
      ...onboardingCategories.where((category) => category.trim().isNotEmpty),
      ...taskSections.where((section) => section != 'Urgent'),
      'Urgent',
    };
    return values.toList();
  }

  @override
  void onInit() {
    super.onInit();
    ever<List<Map<String, dynamic>>>(_storage.tasks, (_) => _loadTasks());
    _loadTasks();
  }

  List<TaskSection> get sections {
    final filtered = tasks.where(_matchesFilters).toList();
    final sectionNames = <String>[
      if (filtered.any((task) => task.section == 'Urgent')) 'Urgent',
      ...filtered
          .map((task) => task.section)
          .where((section) => section != 'Urgent')
          .toSet(),
    ];

    return sectionNames
        .map(
          (section) => TaskSection(
            title: section,
            countColor: _sectionColor(section),
            tasks: filtered.where((task) => task.section == section).toList(),
          ),
        )
        .where((section) => section.tasks.isNotEmpty)
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void updateSearch(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  Future<void> toggleTask(TaskListItem task) async {
    final index = tasks.indexOf(task);
    if (index == -1) return;
    tasks[index].isDone = !tasks[index].isDone;
    tasks.refresh();
    await _storage.updateTask(tasks[index].toStorageMap());
  }

  Future<void> addTask({
    required String title,
    required String category,
    required String dueDate,
    bool isUrgent = false,
  }) async {
    final section = isUrgent ? 'Urgent' : _sectionFromCategory(category);
    await _storage.addTask(
      title: title,
      section: section,
      time: dueDate,
      iconCodePoint: Icons.event_rounded.codePoint,
      priority: isUrgent ? 'High Priority' : null,
      isUrgent: isUrgent,
    );
  }

  void addTaskStub() {
    Get.snackbar('Add task', 'Task creation is ready for the next step.');
  }

  bool _matchesFilters(TaskListItem task) {
    final category = selectedCategory.value;
    final matchesCategory = category == 'All' ||
        task.section == category ||
        (category == 'Urgent' && task.isUrgent);
    final query = searchQuery.value;
    final matchesSearch = query.isEmpty ||
        task.title.toLowerCase().contains(query) ||
        task.section.toLowerCase().contains(query) ||
        (task.priority?.toLowerCase().contains(query) ?? false);

    return matchesCategory && matchesSearch;
  }

  String _sectionFromCategory(String category) {
    if (category == 'Urgent') return 'Urgent';
    if (category == 'Work & Career') return 'Work';
    return category;
  }

  void _loadTasks() {
    tasks.assignAll(_storage.tasks.map(TaskListItem.fromStorageMap));
  }

  Color _sectionColor(String section) {
    if (section == 'Urgent') return const Color(0xFFC00000);
    if (section == 'Personal') return AppTaskColors.green;
    return AppTaskColors.primary;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class AppTaskColors {
  static const primary = Color(0xFF2D2B8F);
  static const green = Color(0xFF087A45);
}
