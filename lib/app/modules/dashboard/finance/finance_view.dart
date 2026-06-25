import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../widgets/dashboard_scaffold.dart';
import '../widgets/finance_details_dialog.dart';
import '../widgets/notification_bell.dart';
import 'finance_controller.dart';

class FinanceView extends GetView<FinanceController> {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      activeRoute: AppRoutes.finance,
      child: Column(
        children: [
          const _FinanceTopBar(),
          Expanded(
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 116),
                children: [
                  _TotalBalanceCard(controller: controller),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniFinanceCard(
                          label: 'THIS MONTH',
                          value: Helpers.currency(controller.monthlySpend.value)
                              .replaceAll('.00', ''),
                          progress: controller.monthlySpendProgress.value,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _MiniFinanceCard(
                          label: 'SAVINGS GOAL',
                          value:
                              '${(controller.savingsGoalProgress.value * 100).round()}%',
                          progress: controller.savingsGoalProgress.value,
                          color: const Color(0xFF54D6A7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent Activity',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.toggleActivityView,
                        child: Text(
                          controller.showAllActivities.value
                              ? 'Show Less'
                              : 'View All',
                          style: TextStyle(
                            color: AppTheme.primaryAccent(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (controller.visibleActivities.isEmpty)
                    const _EmptyFinanceActivities()
                  else
                    ..._activitySections(context, controller.visibleActivities),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _activitySections(
    BuildContext context,
    List<FinanceActivity> activities,
  ) {
    final sections = <Widget>[];
    var currentDay = '';

    for (final activity in activities) {
      if (activity.dayLabel != currentDay) {
        currentDay = activity.dayLabel;
        sections.add(
          Padding(
            padding: EdgeInsets.only(
              top: sections.isEmpty ? 0 : 26,
              bottom: 18,
            ),
            child: Text(
              currentDay,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryText(context).withValues(
                      alpha: 0.84,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      }

      sections.add(
        _ActivityTile(
          activity: activity,
          onLongPress: () => showFinanceDetailsDialog(
            context,
            FinanceDetailsData(
              title: activity.title,
              category: activity.category,
              amount: activity.amount,
              createdAt: activity.createdAt,
              occurredAt: activity.occurredAt,
              notes: activity.notes,
            ),
          ),
        ),
      );
    }

    return sections;
  }
}

class _FinanceTopBar extends StatelessWidget {
  const _FinanceTopBar();

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18,
        left: 24,
        right: 18,
        bottom: 18,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.surface(context),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: AppTheme.primary.withValues(
                alpha: isDark ? 0.22 : 0.12,
              ),
              child: Icon(
                Icons.person_rounded,
                color: isDark ? const Color(0xFFB4B5FF) : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Finance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryAccent(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const NotificationBell(),
        ],
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final primaryText = AppTheme.primaryText(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL BALANCE',
            style: TextStyle(
              color: primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 13),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              Helpers.currency(controller.totalBalance.value),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryAccent(context),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '${controller.monthlyChange.value >= 0 ? '+' : ''}${controller.monthlyChange.value.toStringAsFixed(1)}% from last month',
                style: TextStyle(
                  color: controller.monthlyChange.value >= 0
                      ? AppTheme.accent
                      : AppTheme.urgent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFinanceActivities extends StatelessWidget {
  const _EmptyFinanceActivities();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 42),
      child: Center(
        child: Text(
          'No transactions yet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.secondaryText(context),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _MiniFinanceCard extends StatelessWidget {
  const _MiniFinanceCard({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final primaryText = AppTheme.primaryText(context);
    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
      decoration: BoxDecoration(
        color: AppTheme.softFill(context).withValues(
          alpha: AppTheme.isDark(context) ? 0.72 : 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: primaryText,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 5,
              color: color,
              backgroundColor: const Color(0xFFD5DFF1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.onLongPress,
  });

  final FinanceActivity activity;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final amountColor =
        activity.isIncome ? AppTheme.accent : AppTheme.primaryText(context);
    final amountPrefix = activity.isIncome ? '+' : '-';
    final amount = Helpers.currency(activity.amount.abs());
    final primaryText = AppTheme.primaryText(context);
    final secondaryText = AppTheme.secondaryText(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(activity.backgroundColorValue),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconData(activity.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Color(activity.iconColorValue),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$amountPrefix$amount',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  activity.time,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
