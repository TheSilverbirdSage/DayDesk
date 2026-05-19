import 'package:get/get.dart';

import '../../../data/models/task_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/onboarding_service.dart';

class HomeController extends GetxController {
  final userName = 'Alex'.obs;
  final todayTaskCount = 0.obs;
  final dailyBudget = 200.0.obs;
  final spent = 0.0.obs;
  final savingsGoal = 2400.0.obs;
  final workProgress = 0.0.obs;

  final tasks = <TaskModel>[].obs;

  LocalStorageService get _storage => Get.find<LocalStorageService>();

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<OnboardingService>()) return;
    final onboarding = Get.find<OnboardingService>();
    if (onboarding.name.value.isNotEmpty) {
      userName.value = onboarding.name.value;
    }
    dailyBudget.value = onboarding.dailyBudget.value;
    savingsGoal.value = onboarding.savingsGoal.value;
    ever<List<Map<String, dynamic>>>(_storage.tasks, (_) => _loadDashboard());
    ever<List<Map<String, dynamic>>>(
      _storage.financeActivities,
      (_) => _loadDashboard(),
    );
    _loadDashboard();
  }

  double get progress =>
      dailyBudget.value == 0 ? 0 : spent.value / dailyBudget.value;
  double get remaining => dailyBudget.value - spent.value;

  Future<void> toggleTask(TaskModel task) async {
    final index = tasks.indexOf(task);
    if (index == -1) return;

    final current = tasks[index];
    current.isDone = !current.isDone;
    current.subtitle = current.isDone
        ? 'Done at 7:30 AM'
        : current.subtitle.replaceFirst('Done at ', '');
    tasks.refresh();

    final storedTask = _storage.tasks.firstWhereOrNull(
      (item) => item['id'] == current.id,
    );
    if (storedTask == null) return;
    await _storage.updateTask({
      ...storedTask,
      'isDone': current.isDone,
      'completedText': current.isDone ? current.subtitle : null,
    });
  }

  void _loadDashboard() {
    final storedTasks = _storage.tasks;
    todayTaskCount.value =
        storedTasks.where((task) => task['isDone'] != true).length;
    final completedTasks =
        storedTasks.where((task) => task['isDone'] == true).length;
    workProgress.value =
        storedTasks.isEmpty ? 0 : completedTasks / storedTasks.length;

    tasks.assignAll(
      storedTasks.take(3).map(
            (task) => TaskModel(
              id: task['id'] as String? ?? '',
              title: task['title'] as String? ?? 'Untitled task',
              subtitle: task['isDone'] == true
                  ? (task['completedText'] as String? ?? 'Completed')
                  : (task['time'] as String? ?? 'Today'),
              badge: task['isUrgent'] == true
                  ? 'URGENT'
                  : (task['section'] as String? ?? '').toUpperCase(),
              isDone: task['isDone'] as bool? ?? false,
            ),
          ),
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    spent.value = _storage.financeActivities.fold<double>(0, (sum, activity) {
      final date = DateTime.tryParse(activity['occurredAt'] as String? ?? '');
      if (date == null || DateTime(date.year, date.month, date.day) != today) {
        return sum;
      }
      final amount = (activity['amount'] as num?)?.toDouble() ?? 0;
      return amount < 0 ? sum + amount.abs() : sum;
    });
  }
}
