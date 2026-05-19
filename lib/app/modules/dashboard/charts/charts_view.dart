import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../widgets/dashboard_scaffold.dart';
import '../widgets/notification_bell.dart';
import 'charts_controller.dart';

class ChartsView extends GetView<ChartsController> {
  const ChartsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      activeRoute: AppRoutes.charts,
      child: Column(
        children: [
          const _InsightsTopBar(),
          Expanded(
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.fromLTRB(14, 26, 14, 106),
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _MostExpensiveCard(controller: controller)),
                      const SizedBox(width: 18),
                      Expanded(
                          child: _CompletionRateCard(controller: controller)),
                    ],
                  ),
                  const SizedBox(height: 34),
                  _WeeklySpendingCard(controller: controller),
                  const SizedBox(height: 34),
                  _TaskCompletionCard(controller: controller),
                  const SizedBox(height: 34),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Top Categories',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.toggleCategories,
                        child: Text(
                          controller.showAllCategories.value
                              ? 'Show less'
                              : 'View all',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ...controller.visibleCategories.map(
                    (category) => _CategoryTile(category: category),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsTopBar extends StatelessWidget {
  const _InsightsTopBar();

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: AppTheme.background,
            child: CircleAvatar(
              radius: 19,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person_rounded, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primary,
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

class _MostExpensiveCard extends StatelessWidget {
  const _MostExpensiveCard({required this.controller});

  final ChartsController controller;

  @override
  Widget build(BuildContext context) {
    return _InsightSummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CapsLabel('MOST EXPENSIVE'),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              controller.mostExpensiveCategory.value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.urgent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: Color(0xFF9D0000), size: 17),
                const SizedBox(width: 5),
                Text(
                  '${controller.mostExpensiveChange.value.round()}%',
                  style: const TextStyle(
                    color: Color(0xFF9D0000),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionRateCard extends StatelessWidget {
  const _CompletionRateCard({required this.controller});

  final ChartsController controller;

  @override
  Widget build(BuildContext context) {
    return _InsightSummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CapsLabel('COMPLETION RATE'),
          const SizedBox(height: 16),
          Text(
            '${(controller.completionRate.value * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.accent,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: controller.completionRate.value,
              minHeight: 5,
              color: const Color(0xFF45D59F),
              backgroundColor: const Color(0xFFD5DFF1),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightSummaryCard extends StatelessWidget {
  const _InsightSummaryCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(16, 24, 14, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WeeklySpendingCard extends StatelessWidget {
  const _WeeklySpendingCard({required this.controller});

  final ChartsController controller;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Spending',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      controller.weekRange.value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Helpers.currency(controller.weeklySpending.value),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.weeklyDelta.value < 0 ? '-' : '+'}${Helpers.currency(controller.weeklyDelta.value.abs())} vs last week',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 178,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: controller.weeklyBars
                  .map((bar) => Expanded(child: _SpendingBar(bar: bar)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingBar extends StatelessWidget {
  const _SpendingBar({required this.bar});

  final WeeklySpend bar;

  @override
  Widget build(BuildContext context) {
    const maxHeight = 140.0;
    final fillHeight =
        (bar.value.clamp(0, 1) * maxHeight).clamp(18.0, maxHeight);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 40,
          height: maxHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD5DFF1),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              Container(
                height: fillHeight,
                decoration: BoxDecoration(
                  color: bar.isHighlighted
                      ? AppTheme.primary
                      : const Color(0xFF5A50B3),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(bar.value > 0.92 ? 9 : 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          bar.day,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TaskCompletionCard extends StatelessWidget {
  const _TaskCompletionCard({required this.controller});

  final ChartsController controller;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Completion',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter:
                      _CompletionDonutPainter(controller.completionMetrics),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${controller.totalTasksDone.value}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'DONE',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
              Expanded(
                child: Column(
                  children: controller.completionMetrics
                      .map((metric) => _CompletionLegend(metric: metric))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionLegend extends StatelessWidget {
  const _CompletionLegend({required this.metric});

  final CompletionMetric metric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration:
                BoxDecoration(color: metric.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              metric.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
            ),
          ),
          Text(
            '${metric.count}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final TopCategory category;

  @override
  Widget build(BuildContext context) {
    final isPositive = category.changePercent > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(24, 22, 26, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: category.iconColor, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.transactions} transactions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.currency(category.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${isPositive ? '+' : ''}${category.changePercent.round()}%',
                style: TextStyle(
                  color: isPositive ? AppTheme.urgent : AppTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CapsLabel extends StatelessWidget {
  const _CapsLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CompletionDonutPainter extends CustomPainter {
  const _CompletionDonutPainter(this.metrics);

  final List<CompletionMetric> metrics;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.22;
    final rect = Offset.zero & size;
    final ringRect = rect.deflate(strokeWidth / 2);
    final basePaint = Paint()
      ..color = const Color(0xFFDCE8FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(ringRect, 0, math.pi * 2, false, basePaint);

    final total = metrics.fold<int>(0, (sum, metric) => sum + metric.count);
    if (total == 0) return;

    var start = math.pi;
    const gap = 0.018;
    for (final metric in metrics) {
      final sweep = (metric.count / total) * math.pi * 2;
      final paint = Paint()
        ..color = metric.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(ringRect, start, math.max(0, sweep - gap), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _CompletionDonutPainter oldDelegate) {
    return oldDelegate.metrics != metrics;
  }
}
