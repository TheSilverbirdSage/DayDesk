import 'package:get/get.dart';

import '../../../data/services/local_storage_service.dart';
import '../../../data/services/onboarding_service.dart';

class FinanceActivity {
  const FinanceActivity({
    required this.title,
    required this.category,
    required this.amount,
    required this.time,
    required this.dayLabel,
    required this.iconCodePoint,
    required this.iconColorValue,
    required this.backgroundColorValue,
    this.createdAt,
    this.occurredAt,
    this.notes,
  });

  final String title;
  final String category;
  final double amount;
  final String time;
  final String dayLabel;
  final int iconCodePoint;
  final int iconColorValue;
  final int backgroundColorValue;
  final DateTime? createdAt;
  final DateTime? occurredAt;
  final String? notes;

  bool get isIncome => amount > 0;

  factory FinanceActivity.fromStorageMap(Map<String, dynamic> map) {
    return FinanceActivity(
      title: map['title'] as String? ?? 'Untitled transaction',
      category: map['category'] as String? ?? 'General',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      time: map['time'] as String? ?? '',
      dayLabel: map['dayLabel'] as String? ?? 'Today',
      iconCodePoint: map['iconCodePoint'] as int? ?? 0xe227,
      iconColorValue: map['iconColorValue'] as int? ?? 0xFF2D2B8F,
      backgroundColorValue: map['backgroundColorValue'] as int? ?? 0xFFEDEBFA,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      occurredAt: map['occurredAt'] != null
          ? DateTime.tryParse(map['occurredAt'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }
}

class FinanceController extends GetxController {
  final totalBalance = 0.0.obs;
  final monthlySpend = 0.0.obs;
  final monthlySpendProgress = 0.0.obs;
  final savingsGoalProgress = 0.0.obs;
  final monthlyChange = 0.0.obs;
  final showAllActivities = false.obs;

  final activities = <FinanceActivity>[].obs;

  LocalStorageService get _storage => Get.find<LocalStorageService>();

  List<FinanceActivity> get visibleActivities =>
      showAllActivities.value ? activities : activities.take(5).toList();

  @override
  void onInit() {
    super.onInit();
    ever<List<Map<String, dynamic>>>(
      _storage.financeActivities,
      (_) => _loadActivities(),
    );
    _loadActivities();
  }

  void toggleActivityView() {
    showAllActivities.toggle();
  }

  Future<void> addActivity({
    required String title,
    required String category,
    required double amount,
    DateTime? occurredAt,
  }) {
    final style = _styleForCategory(category);
    return _storage.addFinanceActivity(
      title: title,
      category: category,
      amount: amount,
      iconCodePoint: style.iconCodePoint,
      iconColorValue: style.iconColorValue,
      backgroundColorValue: style.backgroundColorValue,
      occurredAt: occurredAt,
    );
  }

  void _loadActivities() {
    activities.assignAll(
      _storage.financeActivities.map(FinanceActivity.fromStorageMap),
    );
    _recalculateSummary();
  }

  void _recalculateSummary() {
    final now = DateTime.now();
    final currentMonth = _storage.financeActivities.where((activity) {
      final date = DateTime.tryParse(activity['occurredAt'] as String? ?? '');
      return date != null && date.year == now.year && date.month == now.month;
    }).toList();
    final lastMonth = _storage.financeActivities.where((activity) {
      final date = DateTime.tryParse(activity['occurredAt'] as String? ?? '');
      if (date == null) return false;
      final previousMonth = DateTime(now.year, now.month - 1);
      return date.year == previousMonth.year &&
          date.month == previousMonth.month;
    }).toList();

    totalBalance.value = activities.fold<double>(
      0,
      (sum, activity) => sum + activity.amount,
    );
    monthlySpend.value = currentMonth.fold<double>(
      0,
      (sum, activity) => sum + _expenseAmount(activity),
    );
    final dailyBudget = Get.isRegistered<OnboardingService>()
        ? Get.find<OnboardingService>().dailyBudget.value
        : 0.0;
    monthlySpendProgress.value =
        dailyBudget <= 0 ? 0 : monthlySpend.value / (dailyBudget * 30);

    final savingsGoal = Get.isRegistered<OnboardingService>()
        ? Get.find<OnboardingService>().savingsGoal.value
        : 0.0;
    savingsGoalProgress.value = savingsGoal <= 0
        ? 0
        : totalBalance.value.clamp(0, savingsGoal) / savingsGoal;

    final lastMonthSpend = lastMonth.fold<double>(
      0,
      (sum, activity) => sum + _expenseAmount(activity),
    );
    monthlyChange.value = lastMonthSpend == 0
        ? 0
        : ((monthlySpend.value - lastMonthSpend) / lastMonthSpend) * 100;
  }

  double _expenseAmount(Map<String, dynamic> activity) {
    final amount = (activity['amount'] as num?)?.toDouble() ?? 0;
    return amount < 0 ? amount.abs() : 0;
  }

  _FinanceActivityStyle _styleForCategory(String category) {
    return switch (category) {
      'Income' => const _FinanceActivityStyle(0xe57d, 0xFF087A45, 0xFFE9FBEF),
      'Transport' =>
        const _FinanceActivityStyle(0xe530, 0xFF1F54D9, 0xFFEFF3FF),
      'Food & Drinks' =>
        const _FinanceActivityStyle(0xe532, 0xFFFF6B00, 0xFFFFF2E5),
      'Housing' => const _FinanceActivityStyle(0xe88a, 0xFF1877F2, 0xFFEAF4FF),
      _ => const _FinanceActivityStyle(0xe227, 0xFF2D2B8F, 0xFFEDEBFA),
    };
  }
}

class _FinanceActivityStyle {
  const _FinanceActivityStyle(
    this.iconCodePoint,
    this.iconColorValue,
    this.backgroundColorValue,
  );

  final int iconCodePoint;
  final int iconColorValue;
  final int backgroundColorValue;
}
