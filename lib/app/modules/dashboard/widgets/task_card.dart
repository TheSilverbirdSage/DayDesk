import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
  });

  final TaskModel task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: task.isDone ? Colors.transparent : AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: task.isDone
            ? Border.all(color: Colors.black.withValues(alpha: 0.035))
            : null,
        boxShadow: task.isDone
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone
                    ? AppTheme.primary.withValues(alpha: 0.72)
                    : Colors.transparent,
                border: Border.all(
                  color: task.isDone
                      ? AppTheme.primary.withValues(alpha: 0.72)
                      : AppTheme.primary.withValues(alpha: 0.28),
                  width: 2.2,
                ),
              ),
              child: task.isDone
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 21)
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: task.isDone
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _subtitleIcon,
                      color: task.isDone
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        task.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: task.isDone
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (task.badge.isNotEmpty) ...[
            const SizedBox(width: 12),
            _TaskBadge(label: task.badge),
          ],
        ],
      ),
    );
  }

  IconData get _subtitleIcon {
    if (task.isDone) return Icons.check_rounded;
    if (task.subtitle.contains(':')) return Icons.schedule_rounded;
    return Icons.shopping_cart_outlined;
  }
}

class _TaskBadge extends StatelessWidget {
  const _TaskBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isUrgent = label == 'URGENT';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isUrgent ? 0 : 12,
        vertical: isUrgent ? 0 : 8,
      ),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.transparent : AppTheme.todayBadge,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isUrgent ? AppTheme.urgent : AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
