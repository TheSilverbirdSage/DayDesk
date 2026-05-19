import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/local_storage_service.dart';

class WeeklySpend {
  const WeeklySpend({
    required this.day,
    required this.value,
    this.isHighlighted = false,
  });

  final String day;
  final double value;
  final bool isHighlighted;
}

class CompletionMetric {
  const CompletionMetric({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

class TopCategory {
  const TopCategory({
    required this.name,
    required this.transactions,
    required this.amount,
    required this.changePercent,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String name;
  final int transactions;
  final double amount;
  final double changePercent;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

class ChartsController extends GetxController {
  final mostExpensiveCategory = 'None yet'.obs;
  final mostExpensiveChange = 0.0.obs;
  final completionRate = 0.0.obs;
  final weeklySpending = 0.0.obs;
  final weeklyDelta = 0.0.obs;
  final weekRange = ''.obs;
  final totalTasksDone = 0.obs;
  final showAllCategories = false.obs;

  final weeklyBars = <WeeklySpend>[].obs;
  final completionMetrics = <CompletionMetric>[].obs;
  final topCategories = <TopCategory>[].obs;

  LocalStorageService get _storage => Get.find<LocalStorageService>();

  List<TopCategory> get visibleCategories =>
      showAllCategories.value ? topCategories : topCategories.take(2).toList();

  @override
  void onInit() {
    super.onInit();
    ever<List<Map<String, dynamic>>>(_storage.tasks, (_) => _recalculate());
    ever<List<Map<String, dynamic>>>(
      _storage.financeActivities,
      (_) => _recalculate(),
    );
    _recalculate();
  }

  void toggleCategories() {
    showAllCategories.toggle();
  }

  void _recalculate() {
    _recalculateTasks();
    _recalculateSpending();
  }

  void _recalculateTasks() {
    final tasks = _storage.tasks;
    final doneTasks = tasks.where((task) => task['isDone'] == true).toList();
    totalTasksDone.value = doneTasks.length;
    completionRate.value = tasks.isEmpty ? 0 : doneTasks.length / tasks.length;

    final grouped = <String, int>{};
    for (final task in doneTasks) {
      final section = task['section'] as String? ?? 'Other';
      grouped[section] = (grouped[section] ?? 0) + 1;
    }

    final colors = [
      const Color(0xFF24149C),
      const Color(0xFF087A45),
      const Color(0xFF9A0029),
      const Color(0xFF1F54D9),
    ];
    var index = 0;
    completionMetrics.assignAll(
      grouped.entries.map((entry) {
        final metric = CompletionMetric(
          label: entry.key,
          count: entry.value,
          color: colors[index % colors.length],
        );
        index += 1;
        return metric;
      }),
    );
  }

  void _recalculateSpending() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final startOfPreviousWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    weekRange.value =
        '${_monthName(startOfWeek.month)} ${startOfWeek.day} - ${_monthName(endOfWeek.month)} ${endOfWeek.day}';

    final currentWeek = _expensesBetween(startOfWeek, endOfWeek);
    final previousWeek = _expensesBetween(
      startOfPreviousWeek,
      startOfWeek.subtract(const Duration(days: 1)),
    );

    weeklySpending.value = currentWeek.fold<double>(
      0,
      (sum, activity) => sum + _expenseAmount(activity),
    );
    weeklyDelta.value = weeklySpending.value -
        previousWeek.fold<double>(
          0,
          (sum, activity) => sum + _expenseAmount(activity),
        );

    final dailyTotals = List<double>.filled(7, 0);
    for (final activity in currentWeek) {
      final date = DateTime.tryParse(activity['occurredAt'] as String? ?? '');
      if (date == null) continue;
      dailyTotals[date.weekday - 1] += _expenseAmount(activity);
    }
    final maxDay =
        dailyTotals.fold<double>(0, (max, value) => value > max ? value : max);
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    weeklyBars.assignAll(
      List.generate(
        7,
        (index) => WeeklySpend(
          day: labels[index],
          value: maxDay == 0 ? 0 : dailyTotals[index] / maxDay,
          isHighlighted: index == now.weekday - 1,
        ),
      ),
    );

    _recalculateTopCategories();
  }

  void _recalculateTopCategories() {
    final expenses = _storage.financeActivities.where((activity) {
      return ((activity['amount'] as num?)?.toDouble() ?? 0) < 0;
    });
    final totals = <String, ({int transactions, double amount})>{};

    for (final expense in expenses) {
      final category = expense['category'] as String? ?? 'General';
      final current = totals[category];
      totals[category] = (
        transactions: (current?.transactions ?? 0) + 1,
        amount: (current?.amount ?? 0) + _expenseAmount(expense),
      );
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    mostExpensiveCategory.value =
        sorted.isEmpty ? 'None yet' : sorted.first.key;

    topCategories.assignAll(
      sorted.map((entry) {
        final style = _styleForCategory(entry.key);
        return TopCategory(
          name: entry.key,
          transactions: entry.value.transactions,
          amount: entry.value.amount,
          changePercent: 0,
          icon: IconData(style.iconCodePoint, fontFamily: 'MaterialIcons'),
          iconColor: Color(style.iconColorValue),
          backgroundColor: Color(style.backgroundColorValue),
        );
      }),
    );
  }

  List<Map<String, dynamic>> _expensesBetween(DateTime start, DateTime end) {
    final inclusiveEnd = end.add(const Duration(days: 1));
    return _storage.financeActivities.where((activity) {
      final date = DateTime.tryParse(activity['occurredAt'] as String? ?? '');
      if (date == null) return false;
      return !date.isBefore(start) &&
          date.isBefore(inclusiveEnd) &&
          _expenseAmount(activity) > 0;
    }).toList();
  }

  double _expenseAmount(Map<String, dynamic> activity) {
    final amount = (activity['amount'] as num?)?.toDouble() ?? 0;
    return amount < 0 ? amount.abs() : 0;
  }

  _CategoryStyle _styleForCategory(String category) {
    return switch (category) {
      'Food & Drinks' => const _CategoryStyle(0xe532, 0xFF087A45, 0xFFE7F3EF),
      'Transport' => const _CategoryStyle(0xe530, 0xFF1F54D9, 0xFFEAF4FF),
      'Housing' => const _CategoryStyle(0xe88a, 0xFF1877F2, 0xFFEAF4FF),
      _ => const _CategoryStyle(0xe227, 0xFF2D2B8F, 0xFFEDEBFA),
    };
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
}

class _CategoryStyle {
  const _CategoryStyle(
    this.iconCodePoint,
    this.iconColorValue,
    this.backgroundColorValue,
  );

  final int iconCodePoint;
  final int iconColorValue;
  final int backgroundColorValue;
}
