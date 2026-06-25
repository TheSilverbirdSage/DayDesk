import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../widgets/dashboard_scaffold.dart';
import '../widgets/notification_bell.dart';
import '../widgets/task_card.dart';
import '../widgets/task_details_dialog.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return DashboardScaffold(
      activeRoute: AppRoutes.home,
      child: SafeArea(
        bottom: false,
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 112),
            children: [
              const _TopBar(),
              const SizedBox(height: 30),
              Text(
                'Hello, ${controller.userName.value}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                controller.todayTaskCount.value == 0
                    ? "You're all clear on tasks for now."
                    : "You have ${controller.todayTaskCount.value} tasks to complete and ${controller.remaining >= 0 ? "you're under budget" : "you're over budget"}.",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryText(context).withValues(
                        alpha: 0.86,
                      ),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 24),
              _DailyBudgetCard(
                  spent: controller.spent.value,
                  dailyBudget: controller.dailyBudget.value),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      backgroundColor: AppTheme.primary,
                      icon: Icons.trending_up_rounded,
                      iconColor: Colors.white,
                      label: 'Savings Goal',
                      value: Helpers.currency(controller.savingsGoal.value)
                          .replaceAll('.00', ''),
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _StatCard(
                      backgroundColor: isDark
                          ? AppTheme.elevatedSurface(context)
                          : AppTheme.statBlue,
                      icon: Icons.stacked_bar_chart_rounded,
                      iconColor:
                          isDark ? const Color(0xFFB4B5FF) : AppTheme.primary,
                      label: 'Work Progress',
                      value:
                          '${(controller.workProgress.value * 100).round()}%',
                      textColor: AppTheme.primaryText(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Priority Tasks',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.tasks),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppTheme.primaryAccent(context),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...controller.tasks.map(
                (task) => TaskCard(
                  task: task,
                  onToggle: () => controller.toggleTask(task),
                  onDelete: () => controller.deleteTask(task),
                  onLongPress: () => showTaskDetailsDialog(
                    context,
                    TaskDetailsData(
                      title: task.title,
                      section: task.badge,
                      createdAt: task.createdAt,
                      scheduledAt: task.scheduledAt,
                      dueLabel: task.subtitle,
                      notes: task.notes,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Row(
      children: [
        Material(
          color: AppTheme.surface(context),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Get.toNamed(AppRoutes.settings),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary.withValues(
                  alpha: isDark ? 0.22 : 0.12,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: isDark ? const Color(0xFFB4B5FF) : AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.secondaryText(context),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              // Text(
              //   'Overview',
              //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
              //         color: AppTheme.primaryAccent(context),
              //         fontWeight: FontWeight.w900,
              //       ),
              // ),
            ],
          ),
        ),
        const NotificationBell(),
      ],
    );
  }
}

class _DailyBudgetCard extends StatelessWidget {
  const _DailyBudgetCard({required this.spent, required this.dailyBudget});

  final double spent;
  final double dailyBudget;

  @override
  Widget build(BuildContext context) {
    final progress =
        dailyBudget == 0 ? 0.0 : (spent / dailyBudget).clamp(0.0, 1.0);
    final remaining = dailyBudget - spent;
    final primaryText = AppTheme.primaryText(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(25),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY BUDGET',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          text: Helpers.currency(spent),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                          children: [
                            TextSpan(
                              text: ' / ${Helpers.currency(dailyBudget)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: primaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8F7DF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: AppTheme.accent, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Spent',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: primaryText.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: AppTheme.accent,
              backgroundColor: AppTheme.softFill(context),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: 'Remaining: ',
              style: TextStyle(
                color: primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: Helpers.currency(remaining),
                  style: const TextStyle(
                      color: AppTheme.accent, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.textColor,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.86),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
